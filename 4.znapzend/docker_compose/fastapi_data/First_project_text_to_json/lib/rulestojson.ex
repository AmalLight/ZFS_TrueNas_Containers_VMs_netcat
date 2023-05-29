
defmodule RulesToJson.Sets do

    def return_data do

        %{ divide:      " "  ,
           to_evidence: "\n" ,
           split_time:  "=>" ,
           split_comma: ","  ,

           to_split_init:                  "|||"   ,
           to_split_next: { "src_plan=" , "src=" } ,

           cond_pool:     "src="      ,
           cond_timeline: "src_plan=" ,

           limit: [ hour:    24 - 1   ,
                    hours:   24 - 1   ,
                    minute:  60 - 1   ,
                    minutes: 60 - 1   , 
                    second:  60 - 1   ,
                    seconds: 60 - 1 ] ,

           order: [ hours:   [ :hours                                              ]   ,
                    hour:    [ :hours, :hour                                       ]   ,
                    minutes: [ :hours, :hour, :minutes                             ]   ,
                    minute:  [ :hours, :hour, :minutes, :minute                    ]   ,
                    seconds: [ :hours, :hour, :minutes, :minute, :seconds          ]   ,
                    second:  [ :hours, :hour, :minutes, :minute, :seconds, :second ] ] ,

           token_time: [ hour:    "hour"    ,
                         hours:   "hours"   ,
                         minute:  "minute"  ,
                         minutes: "minutes" ,
                         second:  "second"  ,
                         seconds: "seconds" ]
        }
    end
end

# -----------------------------------------------------------------
# -----------------------------------------------------------------

defmodule RulesToJson.Main do

   def extract_pool(    [       ]        ), do: []
   def extract_pool     [ head2 | _tail2 ]  do
       IO.puts "pool " <> head2

       :ets.insert( :buckets_registry, { :src , head2 } )

       [[ src: head2 ]]
   end

   # -----------------------------------------------------------------
   # -----------------------------------------------------------------

   def extract_numbers_class _mySets, [], [], collection, class do

       [ good | _ ]= for el <- collection, reduce: [true] do

           acc -> [ h ] = acc

                  cond do
                       h == true -> [ true and ( el in [ "1","2","3","4","5","6","7","8","9","0" ] ) ]
                            true -> [ false ]
                  end
       end
       
       IO.puts [ "collection: " , collection , " class: #{class} is it good: #{good}" ]

       if good == true do

            %{ end: true,  match: collection, class: class }
       else
            %{ end: false, match: [ '0' ],    class: class }
       end
   end

   def extract_numbers_class( _mySets , []    , _listab, _collection,  class ), do: %{ end: false, match: [ '0' ],    class: class }
   def extract_numbers_class   mySets , listaa,     nil, _collection, _class    do
       IO.puts "Codepoints "         <> listaa

       split_listaa = String.codepoints listaa

       match = for el <- Keyword.keys( mySets.token_time ), reduce: %{} do

           acc -> cond do

                ( acc != %{} ) and ( acc.end == true ) -> acc
                true -> extract_numbers_class mySets, split_listaa, String.codepoints( mySets.token_time[ el ] ), [], el
           end
       end

       match
   end

   def extract_numbers_class mySets, listaa, listab,  collection, class do

       [ headb | tailb ] = cond do
                                listab == [] -> [ [] , [] ]
                                true         -> listab
                           end

       [ heada | taila ] = listaa

       cond do
            ( headb == [] ) or ( headb != heada ) -> extract_numbers_class mySets, taila, listab, collection ++ [ heada ], class
            true                                  -> extract_numbers_class mySets, taila,  tailb, collection             , class
       end
   end

   # -----------------------------------------------------------------
   # -----------------------------------------------------------------

   def extract_timeline( :time ,  []                , _mySets, _tag ), do: []
   def extract_timeline  :time ,  [ head3 | _tail3 ],  mySets,  tag    do
       IO.puts  "timeline time " <> head3

       src = :ets.lookup( :buckets_registry, :src )[ :src ]

       if String.contains? head3, mySets.split_time do

            list = String.split head3, mySets.split_time

            collection = for el <- list, reduce: [] do

                acc -> acc ++ extract_timeline :time, [ el ], mySets, length( acc )
            end

            collection
       else
            match = extract_numbers_class mySets, head3, nil, [], nil

            for el <- Map.keys( match ), do: IO.puts [ "Codepoints final result => #{el}" , ": " , "#{match[ el ]}" ]

            match_tag = cond do
                             rem( tag + 1 , 2 ) == 1 -> :Duration
                             rem( tag + 1 , 2 ) == 0 -> :Timeline
                        end

            [[ end: match.end, time: match.match, class: match.class, src: src, tag: match_tag, i: Integer.to_string tag ]]
       end
   end

   # -----------------------------------------------------------------
   # -----------------------------------------------------------------

   def extract_timeline( :comma,   []               , _mySets ), do: []
   def extract_timeline  :comma,   [ head2 | tail2 ],  mySets    do
       IO.puts  "timeline comma " <> head2

       if String.contains? head2, mySets.split_comma do

            collection = for el <- String.split( head2, mySets.split_comma ), reduce: [] do

                acc -> acc ++ extract_timeline :time, [ el ], mySets, 0
            end

            collection ++ extract_timeline :comma, tail2, mySets
       else
            extract_timeline( :time,  [ head2 ], mySets, 0 ) ++
            extract_timeline( :comma,   tail2  , mySets    )
       end
   end

   # -----------------------------------------------------------------
   # -----------------------------------------------------------------

   def extract_pool_timeline(                       [               ], _mySets ), do: []
   def extract_pool_timeline                        [ head1 | tail1 ],  mySets    do
       if head1 != "", do: IO.puts "extract info " <> head1

       if String.contains? head1, mySets.divide do

            [ head2 | tail2 ] = String.split head1, mySets.divide

            IO.puts "extract info find from divide: " <> head2

            cond do
                 head2 == mySets.cond_pool     -> extract_pool(              tail2         ) ++ extract_pool_timeline tail1, mySets
                 head2 == mySets.cond_timeline -> extract_timeline( :comma , tail2, mySets ) ++ extract_pool_timeline tail1, mySets
                 true                          ->                                               extract_pool_timeline tail1, mySets
            end
       else
            extract_pool_timeline tail1, mySets
       end
   end

   # -----------------------------------------------------------------
   # -----------------------------------------------------------------

   def run text, mySets do

       # IO.puts mySets.to_evidence
       IO.puts mySets.to_split_init
       IO.puts mySets.divide

       String.replace( text, mySets.divide, "" )
           |> String.replace( mySets.to_evidence, mySets.to_split_init )
           |> (fn testo ->            { :text            , testo } end).()
           |> (fn inser -> :ets.insert( :buckets_registry, inser ) end).()
       
       IO.puts :ets.lookup( :buckets_registry, :text )[ :text ]
       IO.puts ''

       for n <- Tuple.to_list mySets.to_split_next do

           IO.puts "main split pattern: " <> n

           :ets.lookup( :buckets_registry, :text )[ :text ]

               |> (fn testo -> String.replace( testo, n, n <> mySets.divide ) end).()
               |> (fn testo ->            { :text            ,        testo } end).()
               |> (fn inser -> :ets.insert( :buckets_registry,        inser ) end).()
       end

       IO.puts ''
       text = :ets.lookup( :buckets_registry, :text )[ :text ]
       IO.puts text
       IO.puts ''
       
       text = String.split text, mySets.to_split_init

       collected = extract_pool_timeline text, mySets

       IO.puts ''

       for el <- collected do
           cond            do

               ( :src      in Keyword.keys el ) and
               ( :time not in Keyword.keys el ) -> IO.puts [ ':src is ', el[ :src ] ]
                 :time     in Keyword.keys el   -> IO.puts [

                     'time is '    , el[ :time  ]   ,
                     " class is #{   el[ :class ]}" ,
                     ' for src: '  , el[ :src   ]   ,
                     " with tag: #{  el[ :tag   ]}" ,
                     ' with index ', el[ :i     ]
                 ]
           end
       end

       # -----------------------------------------------------------------
       # -----------------------------------------------------------------

       IO.puts ''

       collected = for el <- collected, reduce: [] do

           acc -> (fn ->

                   if :time in Keyword.keys el do

                        el = Keyword.delete( el, :i )

                        cond do

                             (:time in Keyword.keys el) and (el[ :tag ] == :Duration) -> (fn -> :ets.insert( :buckets_registry,
                             
                                         { :last_Duration , [ class: el[ :class ], time: el[ :time ] ] } )

                                         el = Keyword.put_new( el, :prevc, :missing )
                                         el = Keyword.put_new( el, :prevt, :missing )

                                         IO.puts [ "main Duration injected for time: ", el[ :time ] ]

                               acc ++ [ el ] ; end).()

                             (:time in Keyword.keys el) and (el[ :tag ] == :Timeline) -> (fn ->

                                         last_Duration = :ets.lookup( :buckets_registry , :last_Duration )[ :last_Duration ]

                                         el = Keyword.put_new( el, :prevc, last_Duration[ :class ] )
                                         el = Keyword.put_new( el, :prevt, last_Duration[ :time  ] )

                                         IO.puts [ 'time is '      , el[ :time  ]   ,
                                                   " class is #{     el[ :class ]}" ,
                                                   ' for src: '    , el[ :src   ]   ,
                                                   " with tag: #{    el[ :tag   ]}" ,
                                                   " prev.class #{   el[ :prevc ]}" ,
                                                   ' prev.time is ', el[ :prevt ]   ]

                               acc ++ [ el ] ; end).()
                        end
                   else
                        []
                   end
           end).()
       end

       # -----------------------------------------------------------------
       # -----------------------------------------------------------------

       IO.puts ''

       collected = for el <- collected, reduce: [] do

           acc -> (fn ->

                   el_number = String.to_integer( Enum.join( el[ :time ], "" ) )

                   IO.puts "main processing number: " <> Integer.to_string( el_number )

                   el = Keyword.replace( el, :time, el_number )

                   cond do
                        el[ :end ] == false -> IO.puts "end is #{el[ :end ]} so there was an error of type end for the match."
                                               el = Keyword.put_new( el, :limit_good,    :missing )
                                               el = Keyword.put_new( el, :previous_good, :missing )
                                               acc ++ [ el ]
                        true -> cond do

                            el_number  > mySets.limit[ el[ :class ] ] -> IO.puts "time is " <> Integer.to_string( el_number ) <>
                                                                       " limit error of #{mySets.limit[ el[ :class ] ]}"

                                                                         el = Keyword.put_new( el, :previous_good, :missing )
                                                                         el = Keyword.put_new( el, :limit_good,       false ) ; acc ++ [ el ]
                            el_number <= mySets.limit[ el[ :class ] ] -> el = Keyword.put_new( el, :limit_good,       true  )
                            cond do

                                 el[ :tag ] == :Duration -> IO.puts "all test gone well."
                                                            el = Keyword.put_new( el, :previous_connection, true ) ; acc ++ [ el ]

                                 true -> prev_number = String.to_integer( Enum.join( el[ :prevt ], "" ) )
                                 cond do

                                      ( (   el[ :prevc ] in mySets.order[ el[ :class ] ] ) or
                                        ( ( el[ :prevc ]               == el[ :class ]   ) and ( prev_number >= el_number ) ) ) ->

                                          IO.puts "all test gone well."

                                          el = Keyword.replace( el, :prevt        , prev_number )
                                          el = Keyword.put_new( el, :previous_good, true        ) ; acc ++ [ el ]

                                      true -> IO.puts "previous class is #{el[ :prevc ]}, with previous time " <> Integer.to_string( prev_number ) <>
                                                                                        " encountered an error between previous and current."

                                          el = Keyword.put_new( el, :previous_good, false       ) ; acc ++ [ el ]
                                 end
                            end
                        end
                   end
           end).()
       end

       # -----------------------------------------------------------------
       # -----------------------------------------------------------------

       IO.puts ""
       for el <- collected do
           for key <- Keyword.keys( el ), do: IO.puts Integer.to_string( el[ :time ] ) <> " with key #{key} has value: #{el[ key ]}."
       end

       text_to_save = for el <- collected, reduce: [] do
           acc ->
                 starting_text = cond do
                                    ( length( acc ) == 0 ) -> "{ \"items\": [\n"
                                      true                 -> ""
                                 end

                 ending_text   = cond do
                                    ( length( acc ) == ( length( collected ) - 1 ) ) -> "\n]}"
                                      true                                           -> ""
                                 end

                 text_el_to_save = for key <- Keyword.keys( el ), reduce: [] do
                     acc -> acc ++ [ "\"#{key}\" : \"#{el[ key ]}\"" ]
                 end

                 text_el_2 = "  {\n    " <> Enum.join( text_el_to_save , ",\n    " ) <> "\n  }"

                 acc ++ [ starting_text <> text_el_2 <> ending_text ]
       end

       IO.puts ""       
       IO.puts text_to_save = Enum.join( text_to_save , ",\n" )

       File.write( "/fastapi_data/First_project_text_to_json/static/test_1.json" , text_to_save )
   end
end

# -----------------------------------------------------------------

defmodule RulesToJson do
   use Application

   def start( _type, _args ) do

       argv= System.argv()

       IO.puts "length for args: #{length( argv )}"
       IO.puts [ "args content:\n" , Enum.join( argv, "\n" ) ]
       IO.puts ''

       argv= System.argv()

       text= if ( length( argv ) == 0 ) do

            { :ok , text } = File.read ( "/fastapi_data/First_project_text_to_json/static/test.txt" )
                    text
       else
            [ text | _ ]= argv
              text
       end

       :ets.new :buckets_registry, [ :named_table ]

       mySets = RulesToJson.Sets.return_data

       RulesToJson.Main.run text, mySets

       children = []
       { :ok , _ } = Supervisor.start_link( children, strategy: :one_for_one )
   end
end
