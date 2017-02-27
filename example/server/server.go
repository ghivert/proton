package main

import (
	"fmt"
	"net"
	"log"
	"bufio"
	"strings"
	"strconv"
	"math/rand"
	"time"
	"os"
)

type chanVal struct {
	value []byte
	user *connection
}

type Wall struct {
	x int
	y int
	orient string
}

func newChanVal(value []byte, user *connection) *chanVal {
	return &chanVal {
		value: value,
		user: user,
	}
}

type connection struct {
	socket net.Conn
	name string
	send chan []byte
	score int
}

func newCo(socket net.Conn, name string) *connection {
	return &connection {
		socket: socket,
		name:   name,
		send:   make(chan []byte, 10),
		score:  0,
	}
}

type hub struct {
	clients map[*connection]bool
	broadcast chan []byte
	register chan *connection
	unregister chan *connection
	action chan *chanVal
}

func newHub() *hub {
	return &hub {
		clients:    make(map[*connection]bool),
		broadcast:  make(chan []byte),
		register:   make(chan *connection),
		unregister: make(chan *connection),
		action:     make(chan *chanVal),
	}
}

func (h *hub) run() {

	session_chan := make(chan []byte)
	start_game   := make(chan int, 1)
	var session []byte = nil

	go game(h, session_chan, start_game)

	for {
		select {
		case c := <- h.register:
			h.clients[c] = true
			if session != nil {
				c.send <- session
			}
			start_game <- 1
		case c := <- h.unregister:
			if _, ok := h.clients[c]; ok {
				delete(h.clients, c)
			}
		case m := <- h.broadcast:
			// fmt.Print("Broadcasting : " + string(m[:]))
			for c := range h.clients {
				select {
				case c.send <- m:
				default:
					delete(h.clients, c)
				}
			}
		case m := <- session_chan:
		    session = m
		}
	}
}

func game(h *hub, session chan []byte, start chan int) {
	max_round := 10
	reflexion_time := 240 // seconds
	bid_time := 30 // seconds
	res_time := 45
	max_bid := 1000000000 // 1000000000 is just a random 'big' number


	// waiting for 2 players to start
	<- start
	<- start
	fmt.Fprintln(os.Stderr, "Minimum number of clients reached -> starting the game.")

	/* the game board.
	   a few representations are needed :
	     - just a string for the clients
         - a Wall array (Wall = coordonates + orientation) to check if solutions are valids.
         - a string array helps building those 2 representations
    */
main_loop:
	for {
		board_walls := []string{"(4,1,D)","(6,3,D)","(6,3,B)","(3,5,H)","(3,5,D)",
			"(1,5,B)","(8,6,G)","(8,6,B)","(2,7,H)","(2,7,G)","(8,8,G)","(8,8,H)","(10,1,D)",
			"(14,2,D)","(14,2,B)","(16,2,B)","(10,4,G)","(10,4,H)","(15,5,H)","(15,5,D)",
			"(13,7,G)","(13,7,B)","(9,8,H)","(9,8,D)","(8,9,G)","(8,9,B)","(5,10,G)",
			"(5,10,B)","(1,11,B)","(7,11,G)","(7,11,H)","(8,13,H)","(8,13,D)","(2,14,H)",
			"(2,14,D)","(4,15,B)","(4,15,D)","(5,16,D)","(9,9,D)","(9,9,B)","(14,10,G)",
			"(14,10,B)","(10,12,B)","(10,12,D)","(16,12,B)","(15,14,H)","(15,14,D)",
			"(11,15,G)","(11,15,H)","(12,16,D)"}
		board := strings.Join(board_walls, "")

		board_array := make([]Wall, len(board_walls))
		for i, val := range board_walls {
			vals := strings.Split(val[1:len(val)-1], ",")
			x, _ := strconv.Atoi(vals[0])
			y, _ := strconv.Atoi(vals[1])
			board_array[i] = Wall{x: x, y: y, orient: vals[2]}
		}

		// Notifying the start of the game to the clients.
		session     <- []byte("SESSION/" + board + "/\n")
		h.broadcast <- []byte("SESSION/" + board + "/\n")

		for p := range h.clients {
			p.score = 0
		}

		// the game loop.
		for round_nb := 1; round_nb <= max_round; round_nb++ {

			// If there is only 0 or 1 client, exiting.
			if len(h.clients) < 2 {
				fmt.Fprintln(os.Stderr, "/!\\ Not enough clients, exiting.")
				break main_loop
			}

			// PHASE DE REFLEXION

			/* Generating the puzzle, and generating the string that will be sended to the clients.

           At the same time, we fill the bids hashmap (to avoid iterating one more time through
           the list of players.
           bids hashmap is used to store the bids of the clients and to know which players are
           playing this round.
        */
			enigme := gen_start()
			buffer := []byte("TOUR/" + enigme + "/" + strconv.Itoa(round_nb))
			bids := make(map[string]int)
			for p := range h.clients {
				name := p.name
				score := p.score
				buffer = append(buffer, "(" + name + "," + strconv.Itoa(score) + ")"...)
				bids[name] = max_bid
			}
			buffer = append(buffer, "/\n"...)
			h.broadcast <- buffer
			fmt.Fprintln(os.Stderr, "  ~~~ puzzle sent")

			// a timeout to limit the time of this phase.
			timeout_chan := make(chan int, 1)
			timeout(timeout_chan, reflexion_time)

			fmt.Fprintln(os.Stderr, "*** Reflexion phase")
			var min int = max_bid
			var minName string

		reflexion_phase:
			for {
				select {
				case <- timeout_chan:
					break reflexion_phase
				case action := <- h.action:
					value := action.value
					user  := action.user
					s := strings.Split(string(value[:]), "/")
					if nb, err := strconv.Atoi(s[2]);
					s[0] == "SOLUTION" && s[1] == user.name && err == nil {
						if _, ok := bids[user.name]; ok {
							min = nb
							minName = user.name
							bids[user.name] = nb
							user.send <- []byte("TUASTROUVE/\n")
							h.broadcast <-
								[]byte("ILATROUVE/" + user.name + "/" + s[2] + "/\n")
							break reflexion_phase
						} else {
							fmt.Fprintln(os.Stderr, "/!\\ Not allowed client : ", user.name)
						}
					} else {
						fmt.Fprintln(os.Stderr, "/!\\ Wrong request: ", string(value[:]))
					}
				}
			}

			h.broadcast <- []byte("FINREFLEXION/\n")
			fmt.Fprintln(os.Stderr, "*** Reflexion phase over. Min = ", min)

			// ENCHERES
			timeout_chan = make(chan int)
			timeout(timeout_chan, bid_time)

		encheres_loop:
			for {
				select {
				case <- timeout_chan:
				    for p := range bids {
						if bids[p] < min {
							min = bids[p]
							minName = p
						}
					}
				    if min == max_bid {
						h.broadcast <- []byte("FINENCHERE/null/null/\n")
					} else {
						h.broadcast <- []byte("FINENCHERE/" + minName +
							"/" + strconv.Itoa(min) + "/\n")
					}
				    break encheres_loop
				case action := <- h.action:
				    value := action.value
				    user := action.user
				    s := strings.Split(string(value[:]), "/")
				    if bid, ok := bids[s[1]]; s[0] == "ENCHERE" && s[1] == user.name && ok {
						if nb, err := strconv.Atoi(s[2]); err == nil {
							if bid > nb {
								for p := range bids {
									if bids[p] == nb {
										user.send <- []byte("ECHEC/" + p + "/\n")
										continue encheres_loop
									}
								}
								bids[user.name] = nb
								user.send <- []byte("VALIDATION/\n")
								h.broadcast <- []byte("NOUVELLEENCHERE/" + user.name + "/" +
									strconv.Itoa(nb) + "/\n")
								if nb < min {
									min = nb
									minName = user.name
								}
							} else { // bid <= nb
								user.send <- []byte("ECHEC/" + user.name + "/\n")
							}
						}
					}
				}
			}
			fmt.Fprintln(os.Stderr, "*** Encheres phase over. Min = ", min)

			// RESOLUTION
			res_loop: for {
				if min == max_bid {
					h.broadcast <- []byte("FINRESO/\n")
					break
				}

				delete(bids, minName)

				var nextMsg string
				timeout_chan := make(chan int, 1)
				timeout(timeout_chan, res_time)
				select {
				case <- timeout_chan:
				    nextMsg = "TROPLONG/"
				case action := <- h.action:
				    value := action.value
				    user := action.user
				    s := strings.Split(string(value[:]), "/")
				    if s[0] == "SOLUTION" && s[1] == user.name && s[1] == minName {
						if check_solution(board_array, enigme, s[2], min) {
							fmt.Fprintln(os.Stderr, "*** Round over. Winner = ", user.name)
							h.broadcast <- []byte("BONNE/\n")
							user.score++
							break res_loop
						} else {
							nextMsg = "MAUVAISE/"
						}
					}
				}

				var min_loc int = max_bid
				var minName_loc = "null"
				for p := range bids {
					if bids[p] < min_loc {
						min_loc = bids[p]
						minName_loc = p
					}
				}
				min = min_loc
				minName = minName_loc
				h.broadcast <- []byte(nextMsg + minName + "/\n")
			}
			fmt.Fprintln(os.Stderr, "Tour terminé.")
		}
		buffer := []byte("VAINQUEUR/" + strconv.Itoa(max_round))
		for p := range h.clients {
			name := p.name
			score := p.score
			buffer = append(buffer, "(" + name + "," + strconv.Itoa(score) + ")"...)
		}
		buffer = append(buffer, "/\n"...)
		h.broadcast <- buffer
	}
	os.Exit(1)

}

func gen_start() string {
	target_l := [...]string{"6,3","14,2","10,4","3,5","15,5","8,6","2,7","13,7",
		"4,10","14,10","7,11","10,12","8,13","2,14","15,14","4,15","11,15"}
	colors := []string{"B", "V", "R", "J"}

	res := []string{"", "", "", "", "", ""}
	for i := 0; i < 4; i++ {
	start:
		x := rand.Intn(16) + 1
		y := rand.Intn(16) + 1
		if (x == 8 || x == 9) && (y == 8 || y == 9) {
			goto start
		}
		coord := strconv.Itoa(x) + "," + strconv.Itoa(y)
		for j := 0; j < i; j++ {
			if res[j] == coord {
				goto start
			}
		}
		res[i] = coord
	}

select_target:
	target := target_l[rand.Intn(len(target_l)-1)]
	for j := 0; j < 4; j++ {
		if res[j] == target {
			goto select_target
		}
	}
	res[4] = target
	res[5] = colors[rand.Intn(4)]

	return strings.Join(res, ",")
}


func check_solution(board []Wall, enigme string, sol string, nb_coups int) bool {

	corres := map[string]int{"R": 0, "B": 1, "J": 2, "V": 3}
	if len(sol) / 2 > nb_coups {
		fmt.Fprintln(os.Stderr, "Trop de coups")
		return false
	}
	positions := strings.Split(enigme, ",")

	for len(sol) > 0 {

		robot, ok := corres[sol[:1]]
		if !ok {
			fmt.Fprintln(os.Stderr, "Robot inconnu")
			return false
		}
		dir   := sol[1:2]
		sol    = sol[2:]


		x, _ := strconv.Atoi(positions[robot*2])
		y, _ := strconv.Atoi(positions[robot*2+1])

		switch dir {
		case "H":
			for y > 1 {
				for _, wall := range board {
					if wall.x == x && wall.y == y && wall.orient == "H" {
						goto update_co
					}
					if wall.x == x && wall.y == y-1 && wall.orient == "B" {
						goto update_co
					}
					for i := 0; i < 4; i++ {
						if i != robot {
							x2, _ := strconv.Atoi(positions[i*2])
							y2, _ := strconv.Atoi(positions[i*2+1])
							if x2 == x && y2 == y-1 {
								goto update_co
							}
						}
					}
				}
				y--
			}
		case "B":
			for y < 16 {
				for _, wall := range board {
					if wall.x == x && wall.y == y && wall.orient == "B" {
						goto update_co
					}
					if wall.x == x && wall.y == y+1 && wall.orient == "H" {
						goto update_co
					}
					for i := 0; i < 4; i++ {
						if i != robot {
							x2, _ := strconv.Atoi(positions[i*2])
							y2, _ := strconv.Atoi(positions[i*2+1])
							if x2 == x && y2 == y+1 {
								goto update_co
							}
						}
					}
				}
				y++
			}
		case "G":
			for x > 1 {
				for _, wall := range board {
					if wall.y == y && wall.x == x && wall.orient == "G" {
						goto update_co
					}
					if wall.y == y && wall.x == x-1 && wall.orient == "D" {
						goto update_co
					}
					for i := 0; i < 4; i++ {
						if i != robot {
							x2, _ := strconv.Atoi(positions[i*2])
							y2, _ := strconv.Atoi(positions[i*2+1])
							if x2 == x-1 && y2 == y {
								goto update_co
							}
						}
					}
				}
				x--
			}
		case "D":
			for x < 16 {
				for _, wall := range board {
					if wall.y == y && wall.x == x && wall.orient == "D" {
						goto update_co
					}
					if wall.y == y && wall.x == x+1 && wall.orient == "G" {
						goto update_co
					}
					for i := 0; i < 4; i++ {
						if i != robot {
							x2, _ := strconv.Atoi(positions[i*2])
							y2, _ := strconv.Atoi(positions[i*2+1])
							if x2 == x+1 && y2 == y {
								goto update_co
							}
						}
					}
				}
				x++
			}
		default:
			log.Fatal("Direction inconnue : ", dir)
		}
	update_co:
		positions[robot*2]   = strconv.Itoa(x)
		positions[robot*2+1] = strconv.Itoa(y)
	}

	for i := 0; i < 4; i++ {
		fmt.Fprintln(os.Stderr, i, ":", positions[i*2], ",", positions[i*2+1])
	}

	robot := corres[positions[10]]
	if positions[robot*2] != positions[8] || positions[robot*2+1] != positions[9] {
		return false
	}

	return true
}

// send a 1 on chan c after t seconds
func timeout(c chan int, t int) {
	go func() {
		time.Sleep(time.Second * time.Duration(t))
		c <- 1
	}()
}

func (h *hub) contains(name string) (bool){
	for c := range h.clients {
		if c.name == name {
			return true
		}
	}
	return false
}


func client(c net.Conn, h *hub) {
	fmt.Fprintln(os.Stderr, "   + new client...")

	message, _ := bufio.NewReader(c).ReadString('\n')
	s := strings.Split(string(message), "/")
	if s[0] != "CONNEXION" || s[1] == "" {
		fmt.Fprintln(os.Stderr, "   - bad request from new client.")
		return
	}
	if h.contains(s[1]) {
		fmt.Fprintln(os.Stderr, "   - Client already exists.")
		return
	}

	message = "BIENVENUE/" + s[1] + "/\n"
	c.Write([]byte(message))

	message = "CONNECTE/" + s[1] + "/\n"
	h.broadcast <- []byte(message)

	co := newCo(c, s[1])
	h.register <- co

	fmt.Fprintln(os.Stderr, "   + Client ", s[1], " connected.")

	defer func() {
		fmt.Println("   - Closing client " + s[1])
		h.unregister <- co
		c.Close()
		close(co.send)
	}()

	go func() {
		for message := range co.send {
			fmt.Fprintln(os.Stderr, "  Sending", s[1], ":", string(message[:len(message)-1]))
			if _, err := c.Write(message); err != nil {
				fmt.Fprintln(os.Stderr, "   - Writing error, gonna close client " + s[1] + "...")
				break
			}
		}
		c.Close()
	}()

	for {
		message := make([]byte, 8192)
		if _, err := c.Read(message); err != nil {
			fmt.Fprintln(os.Stderr, "   - Reading error, gonna close client " + s[1] + "...")
			return
		}
		fmt.Fprintln(os.Stderr, "  Reveived: ", string(message[:len(message)-1]))
		go func () {
			s := strings.Split(string(message[:]), "/")
			switch s[0] {
	    	case "SORT":
		    	fmt.Fprintln(os.Stderr, "   - Client ", co.name, " leaving.")
		    	return
			case "CHAT":
				h.broadcast <- message
		    default:
			    h.action <- newChanVal(message, co)
			}
		}()
	}
}


func main() {
	fmt.Fprintln(os.Stderr,"Launching server...\n")

	rand.Seed(time.Now().UTC().UnixNano())

	h := newHub()
	go h.run()

	serv, err := net.Listen("tcp", ":2016")

	if (err != nil) {
		log.Fatal("Server creation:", err)
	}

	for {
		conn, err := serv.Accept()
		if (err != nil) {
			fmt.Println(err)
		} else {
			go client(conn, h)
		}
	}
}
