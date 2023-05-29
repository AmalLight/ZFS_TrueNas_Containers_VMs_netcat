defmodule Groupby.Main do
   use Mix.Config

   :ets.new :buckets_registry, [ :named_table ]

   def run text do

       {status, map_from_json} = JSON.decode( text )

       IO.puts status
       IO.puts ''

       for el <- map_from_json[ "items" ] do

           for key <- Map.keys( el ) do

               IO.puts "#{key} is #{el[ key ]}"
           end
       end

       IO.puts ''

       list_of_map = for el <- map_from_json[ "items" ], reduce: %{} do

           acc ->
                  if Map.get( el, "tag" ) == "Timeline" do

                      src_pool =       el[ "src" ]
                      el = Map.delete( el, "src" )
                      el = Map.delete( el, "tag" )

                      acc = Map.put_new( acc, src_pool,          [] )
                      new_content =      acc[ src_pool              ] ++ [ el ]
                      acc = Map.put(     acc, src_pool, new_content )
                                         acc
                  else
                      acc
                  end
       end

       {status, result} = JSON.encode( list_of_map )
       IO.puts  "#{status} to creating the json from the list of map."

       status = File.write( "/fastapi_data/groupby/static/result.json", result )
       IO.puts  "#{status} to save the json file."

       String.replace( result , ":[{" , ": [\n    { " )

             |> String.replace( "},{", " },\n    { " )

             |> String.replace( "{\"" , "{\n  \"" )

             |> String.replace( "}]}" , " }]\n}" )

             |> IO.puts
       :ok
   end
end

# -----------------------------------------------------------------

defmodule Groupby do
   use Application

   def start( _type, _args ) do

       { :ok , text } = File.read ( "/fastapi_data/First_project_text_to_json/static/test_1.json" )

       IO.puts ''
       IO.puts text

       Groupby.Main.run text

       children = []
       { :ok , _ } = Supervisor.start_link( children, strategy: :one_for_one )
   end
end
