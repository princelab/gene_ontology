require "test_helper"
require 'gene_ontology'
require 'open-uri'
require 'tempfile'

class GeneOntologyTest < Minitest::Test
  GO_OBO_URL = "http://purl.obolibrary.org/obo/go.obo"
  GO_FILENAME = "go.obo"

  def test_that_it_has_a_version_number
    refute_nil ::GeneOntology::VERSION
  end

  def _get_go_obo_file
    puts "Downloading #{GO_FILENAME}, may take a few seconds (~30MB)..."
    puts "[To avoid downloading in future tests, download to pkg root:"
    puts GO_OBO_URL
    STDOUT.flush

    temp_go_file = Tempfile.new()
    temp_go_file.write(open(GO_OBO_URL, &:read))
    temp_go_file.close
    temp_go_file.path
  end

  def test_it_reads_go_obo
    # looks for GO_FILENAME in package root, otherwise downloads to a tempfile
    # of the same name (but in tmpdir)
    go_filename = File.exist?(GO_FILENAME) ?  GO_FILENAME : _get_go_obo_file
    go = GeneOntology.from_file(go_filename)

    assert_match(/\d/, go.header[:'format-version'])
    assert_instance_of(Array, go.header[:subsetdefs])

    first_id = go.id_to_term.keys[0]
    assert_match(/\AGO\:0+\d+/, first_id)

    first_term = go.id_to_term.values[0]
    assert_instance_of Integer, first_term.level
  end
end
