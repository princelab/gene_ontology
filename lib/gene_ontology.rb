
# typical usage: 
#     
#     terms = GeneOntology.new.from_file(filename)
class GeneOntology

  attr_accessor :header
  attr_accessor :id_to_term

  # returns self
  def from_file(filename)
    File.open(filename) do |io|
      @header = parse_header(io)
      @id_to_term = parse_terms(io)
    end
    self
  end

  # returns a header object
  def parse_header(io)
    header = Header.new
    while md=io.gets.match(/^([\w\-]+): (.*)/)
      key, val = md[1].to_sym, md[2]
      if key == :subsetdef
        header.subsetdefs.push(val)
      elsif !header.respond_to?(key)
        header.other[key] = val
      else
        header[key] = val
      end
    end
    header
  end

  # turns is_a links from strings to actual GeneOntology objects
  # returns id_to_term
  def self.link!(terms)
    id_to_term = {} 
    terms.each {|term| id_to_term[term.id] = term }
    terms.each do |term|
      term.is_a.map! {|id| id_to_term[id] }
    end
    id_to_term
  end

  # returns id_to_term
  # is_a points to an array of actual objects
  def parse_terms(io, opts={})
    opts = {:link => true}.merge(opts)
    terms = []
    in_term = false
    while line = io.gets
      if (md=line.match(/^(\w+): (.+)/)) && (in_term)
        key, val = md[1].to_sym, md[2].split(' ! ').first
        if Term::PLURAL.include?(key)
          terms.last.send(key) << val
        else
          terms.last.send("#{key}=", val)
        end
      elsif line !~ /\w/
        in_term = false
      elsif line =~ /\[Term\]/
        terms << Term.new
        in_term = true
      end
    end
    id_to_term = self.class.link!(terms)
    id_to_term.values.each {|term| term.find_level }
    id_to_term
  end

  # synonym, xref, consider and is_a are arrays.  level is how far down the
  # heirarchy the term is.  0 is the top level (molecular function, biological
  # process...)
  class Term
    include Enumerable
#    attr_accessor *%w(id level alt_id intersection_of replaced_by created_by creation_date disjoint_from relationship name namespace def subset comment is_obsolete synonym xref consider is_a).map(&:to_sym)
    attr_accessor *%w(id level alt_id intersection_of replaced_by created_by creation_date disjoint_from relationship name namespace def subset comment is_obsolete synonym xref consider is_a property_value).map(&:to_sym)

    PLURAL = [:synonym, :xref, :consider, :is_a]
    def initialize
      PLURAL.each {|k| self.send("#{k}=", []) }
      self
    end

    def inspect
      "<[#{level}]#{@id}: #{@name} is_a.size=#{@is_a.size}>"
    end

    # starting with that term, traverses upwards in the tree
    def each(&block)
      block.call(self)
      is_a.each do |term| 
        term.each(&block)
      end
    end

    # returns a unique array of go terms at that level
    def trace_to_level(n=1)
      if self.level == n
        [self]
      elsif n > self.level
        []
      else
        self.is_a.map {|anc| anc.trace_to_level(n) }.flatten.uniq
      end
    end

    # returns the number of levels below the top (top 3 categories [mf, bp,
    # cc] are at level 0)
    def find_level
      if @level ; @level
      else
        @level = 
          if @is_a.size == 0 ; 0
          else
            @is_a.map {|term| term.find_level }.min + 1
          end
      end
    end
  end

  # subsetdefs is an array, other is a hash for any key/value pairs not
  # already defined here
  Header = Struct.new( *%w(format-version date saved-by auto-generated-by synonymtypedef systematic_synonym default-namespace remark ontology subsetdefs other).map(&:to_sym) )
  class Header
    def initialize(*args)
      super(*args)
      self.subsetdefs = []
      self.other = {}
      self
    end
  end
end

