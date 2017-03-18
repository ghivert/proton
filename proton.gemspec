Gem::Specification.new do |s|
  s.name        = 'proton'
  s.version     = '0.1.0'
  s.date        = '2017-03-18'
  s.summary     = 'Ruby Electron !'
  s.description = 'Wrapper for Electron in Ruby.'
  s.authors     = ['Guillaume Hivert']
  s.email       = 'guillaume.hivert@outlook.com'
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/ghivert/proton'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['opal']
  s.executables   = ['proton']

  s.add_dependency 'opal', '~> 0.10.3'
end
