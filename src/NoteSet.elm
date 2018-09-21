module NoteSet exposing (Set, empty, insert, keys, member, remove)

import Dict.Any as AnyDict exposing (AnyDict)
import Note exposing (Frequency, Note, Octave, toFrequency)


type alias Set =
    AnyDict Float ( Octave, Note ) ()


empty : Set
empty =
    AnyDict.empty toFrequency


insert : ( Octave, Note ) -> Set -> Set
insert key set =
    AnyDict.insert key () set


remove : ( Octave, Note ) -> Set -> Set
remove =
    AnyDict.remove


member : ( Octave, Note ) -> Set -> Bool
member =
    AnyDict.member


keys : Set -> List ( Octave, Note )
keys =
    AnyDict.keys
