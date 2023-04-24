//
//  MorseCharacter.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-23.
//

import Foundation

enum MorseCharacter {
    
    case dot, dash, unitInterval, letterInterval, wordInterval
    
    var text: String {
        switch self {
        case .dot:
            return "●"
        case .dash:
            return "———"
        case .unitInterval:
            return " "
        case .letterInterval:
            return "   "
        case .wordInterval:
            return "       "
        }
    }
    
    var isUnit: Bool {
        switch self {
        case .dot, .dash:
            return true
        case .unitInterval, .letterInterval, .wordInterval:
            return false
        }
    }
    
}

extension Collection where Element == MorseCharacter {
    
    var morseText: String {
        map(\.text).joined()
    }
    
    var words: [ArraySlice<MorseCharacter>] {
        split(separator: .wordInterval, omittingEmptySubsequences: true)
    }
    
    var letters: [ArraySlice<MorseCharacter>] {
        split(separator: .letterInterval, omittingEmptySubsequences: true)
    }
    
    var units: [MorseCharacter] {
        filter { $0.isUnit }
    }
    
    var latinText: String {
        words.map { word in
            word.letters.compactMap { letter in
                morseDictionary[letter.units]
            }.joined()
        }.joined(separator: " ")
    }
    
}

let morseDictionary: [[MorseCharacter] : String] = [
    [.dot, .dash]: "a",
    [.dash, .dot, .dot, .dot]: "b",
    [.dash, .dot, .dash, .dot]: "c",
    [.dash, .dot, .dot]: "d",
    [.dot]: "e",
    [.dot, .dot, .dash, .dot]: "f",
    [.dash, .dash, .dot]: "g",
    [.dot, .dot, .dot, .dot]: "h",
    [.dot, .dot]: "i",
    [.dot, .dash, .dash, .dash]: "j",
    [.dash, .dot, .dash]: "k",
    [.dot, .dash, .dot, .dot]: "l",
    [.dash, .dash]: "m",
    [.dash, .dot]: "n",
    [.dash, .dash, .dash]: "o",
    [.dot, .dash, .dash, .dot]: "p",
    [.dash, .dash, .dot, .dash]: "q",
    [.dot, .dash, .dot]: "r",
    [.dot, .dot, .dot]: "s",
    [.dash]: "t",
    [.dot, .dot, .dash]: "u",
    [.dot, .dot, .dot, .dash]: "v",
    [.dot, .dash, .dash]: "w",
    [.dash, .dot, .dot, .dash]: "x",
    [.dash, .dot, .dash, .dash]: "y",
    [.dash, .dash, .dot, .dot]: "z",
    [.dot, .dash, .dot, .dash, .dot, .dash]: "1",
    [.dot, .dot, .dash, .dot, .dash, .dash]: "2",
    [.dot, .dot, .dot, .dash, .dash, .dash]: "3",
    [.dot, .dot, .dot, .dot, .dash, .dash]: "4",
    [.dot, .dot, .dot, .dot, .dot, .dash]: "5",
    [.dash, .dot, .dot, .dot, .dot, .dot]: "6",
    [.dash, .dash, .dot, .dot, .dot, .dot]: "7",
    [.dash, .dash, .dash, .dot, .dot, .dot]: "8",
    [.dash, .dash, .dash, .dash, .dot, .dot]: "9",
    [.dash, .dash, .dash, .dash, .dash, .dot]: "0"
]
