# GeneOntology

Parses gene ontology .obo files, links terms through `is_a` and provides
methods to find levels and traverse the tree.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gene_ontology'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gene_ontology

## Usage

```
go = GeneOntology.from_file("gene_ontology.obo")
go.header # => a GeneOntology::Header object
go.id_to_term # => a hash from GO id to the GeneOntology::Term
some_term = go.id_to_term.values.first

# traverse the tree upwards, beginning with the current Term
some_term.each do |term|
  term.name =~ /Plasma Membrane/i
end
some_term.level  # => how many levels down from the top 3
                 # molecular_function, biol comp. etc are level 0
```

## Testing

```
rake test
```

Note: will download http://purl.obolibrary.org/obo/go.obo to a tempfile unless
'go.obo' is already in package root.  Just for testing.

## License

[MIT License](https://opensource.org/licenses/MIT) -- see LICENSE for
copyright info.
