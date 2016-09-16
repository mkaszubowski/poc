defmodule MyLex do
    use LexLuthor

    defrule ~r/^#[^\n]*/, fn(e) ->
                             :ignore end
    defrule ~r/^ +/, :NEWLINE, fn(e) ->
                            { nil, { :indent, String.length(e) } } end
    defrule ~r/^\t+/, :NEWLINE, fn(e) ->
                            { nil, { :indent, 8*String.length(e) } } end
    defrule ~r/^$/, :NEWLINE, fn(e) ->
                             :ignore end
    defrule ~r/^$/, fn(e) ->
                             :ignore end
    defrule ~r/^ +/, fn(e) ->
                             :ignore end
    defrule ~r/^\d+(\.\d+)?/, fn(e) -> { :number, e } end
    defrule ~r/^"/, fn(_) ->  :QUOTED  end
    defrule ~r/^[^"]+/, :QUOTED, fn(e) -> { :name, e } end
    defrule ~r/^"/, :QUOTED, fn(_) -> nil end
    #defrule ~r/^\.([A-Za-z@_]+)/, fn(e) -> { :attrib, String.slice(e,1,String.length(e)-1) } end
    defrule ~r/^\./, fn(e) -> :ATTRIB end
    defrule ~r/^([A-Za-z@_]+)/, :ATTRIB, fn(e) -> {{ :attrib, e }, nil} end
    defrule ~r/^([A-Za-z@_]+)/, fn(e) -> { :key, e } end
    defrule ~r/^=/, fn(e) -> { :oper, e } end
    defrule ~r/^,/, fn(e) -> { :oper, e } end
    defrule ~r/^\n/, fn(_) -> {{:newline, "", 0}, :NEWLINE} end

end

defmodule Statement do
    #TODO wywalić i zostawić tuple, będzie chyba wygodniej obsługiwać?
    defstruct key: "", names: nil, attribs: nil , children: []

    def printStatements nil do
    end

    def printStatements statement do
        IO.puts "MAIN: #{statement.key}"

        for a <- statement.names do
            IO.puts "name #{a.name} : #{a.value}"
        end
        for a <- statement.attribs do
            IO.puts "attribs #{a.name} : #{a.value}"
        end
        for a <- statement.children do
            IO.puts " CHILD"
            printStatements a
        end
        IO.puts "KONIEC!"
    end
end

defmodule MyParse do

    #def getStatement( first, list ) when first.name == :key do
    #end

    def getNames [ ] do
        nil # { [], [], [] }
    end

    def getNames list do
        [ head | rest ] = list

        case head.name do
            :name ->
                { names, attribs, rest } = getNames rest
                names = [ head ] ++ names
                { names, attribs, rest }
            :attrib ->
                { names, attribs, rest } = getNames rest
                attribs = [ head ] ++ attribs
                { names, attribs, rest }
            :indent ->
                { names, attribs, rest } = getNames rest
            :newline ->
                { [], [], rest }
        end
    end

    def parse( [] )  do
    end

    def parse list do
        parse list, 0
    end

    def getChildren [] do
        { [], [] }
    end

    def getChildren [], indent do
        { [], []}
    end

    def getChildren list, indent do
        [ head | rest ] = list
        #IO.puts "--#{head.value} is #{head.indent} (parent #{indent})"

        myindent = head.indent
        case head.name do
            :key when myindent > indent ->
                { statement, rest } = parse list
        #      IO.puts "--#{head.value} #{indent} C--"
                { children, rest } = getChildren rest, indent
                { [ statement  ] ++ children, rest}
             _ ->
         #       IO.puts "#{head.value} NOT HERE #{myindent} <= #{indent}!"
                { [], list }
        end
    end

    def parse( list, indent )  do

        [ head | rest ] = list

        case head.name do
            :key ->
        #         IO.puts "#{head.value} indent #{head.indent} PARSE"
                { names, attribs, rest } = getNames rest
                { children, rest } = getChildren rest, head.indent
        #       IO.puts "#{head.value} indent #{head.indent} END PARSE"
        # TODO: zamienić na tuple??
        #        { { head.value, names, attribs, children }, rest }

                { %Statement{ key: head.value, names: names, attribs: attribs, children: children }, rest }
            _ ->
              IO.puts "parse throw #{head.name}"
                      throw :error

        end
    end


end

defmodule JobSpec do
    def jobName names do
    end

    def jobAttribs attribs do
    end

    def jobChildren children do
        for a <- children do
            handleChild a.key, a.names, a.attribs, a.children
        end
    end

    #TODO: jak manipulować obiektem job? zwracać jakiś tuple po prostu np { :desc, name}?
    def handleChild(key, names, attribs, children ) when key == "short" do
        [ name | rest ] = names
        unless rest == [] do
            throw { :error, "Job description should have only one string as an argument" }
        end
        unless children == [] do
            throw { :error, "Job description should have no children nodes" }
        end
        for a <- names do
          IO.puts "job description = #{a.value}"
        end
    end
    def handleChild(key, names, attribs, children ) when key == "resources" do
        unless names == [] do
            throw { :error, "scripts should have no \"names\"" }
        end
    end

    def handleChild(key, names, attribs, children ) when key == "scripts" do
        unless names == [] do
            throw { :error, "scripts should have no \"names\"" }
        end
    end

    def handleChild(key, names, attribs, children ) when key == "results_visibility" do
        unless names == [] do
            throw { :error, "results_visibility should have no \"names\"" }
        end
        unless children == [] do
            throw { :error, "results_visibility should have no children nodes" }
        end
        for a <- attribs do
          # resourceVisibility a
        end
    end

    def handleChild(key, names, attribs, children ) do
        throw { :error, "An unknown child node \"#{key}\" for \"job\""}
    end


    def main(key, names, attribs, children) when key == "job" do
        IO.puts "ok"

        jobName names
        jobAttribs attribs
        jobChildren children
    end

    def main(key, names, attribs, children) do
        throw { :error, "Top-level statement should be named \"job\", and not \"#{key}\""}
    end

end

defmodule MyApp do
    def main (args) do
        [ file | _ ] = args
        {result , contents } = File.read( file )
        {result, list } = MyLex.lex( contents )
        { main_statement, _ } = MyParse.parse( list )
        Statement.printStatements main_statement
        JobSpec.main( main_statement.key, main_statement.names, main_statement.attribs, main_statement.children )
    end
end
