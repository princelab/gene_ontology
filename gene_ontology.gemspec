
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gene_ontology/version"

Gem::Specification.new do |spec|
  spec.name          = "gene_ontology"
  spec.version       = GeneOntology::VERSION
  spec.authors       = ["John T. Prince"]
  spec.email         = ["jtprince@gmail.com"]

  spec.summary       = %q{Parses gene ontology .obo files}
  spec.description   = %q{Parses gene ontology .obo files, links terms through `is_a` and provides methods to find levels and traverse the tree.}
  spec.homepage      = "https://github.com/princelab/gene_ontology"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
