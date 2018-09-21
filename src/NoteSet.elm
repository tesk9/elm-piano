module NoteSet exposing (Set, empty, insert, keys, member, remove)

import AllDict exposing (AllDict)
import Note exposing (Frequency, Note, Octave, toFrequency)


type alias Set =
    AllDict ( Octave, Note ) () Frequency


empty : Set
empty =
    AllDict.empty toFrequency


insert : ( Octave, Note ) -> Set -> Set
insert key set =
    AllDict.insert key () set


remove : ( Octave, Note ) -> Set -> Set
remove =
    AllDict.remove


member : ( Octave, Note ) -> Set -> Bool
member =
    AllDict.member


keys : Set -> List ( Octave, Note )
keys =
    AllDict.keys
