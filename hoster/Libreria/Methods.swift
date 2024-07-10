//
//  Methods.swift
//  hoster
//
//  Created by Calogero Friscia on 06/05/24.
//

import Foundation

func csTimeFormatter(style:DateFormatter.Style = .full) -> (ora:DateFormatter,data:DateFormatter) {
    // !! Nota Vocale 20.09 AMPM !!
    let time = DateFormatter()
    time.timeStyle = style//.short
   // time.dateFormat = "HH:mm"
   // time.timeZone = .current
  //  time.timeZone = .gmt

    let date = DateFormatter()
   /* date.weekdaySymbols = ["Lun","Mar","Mer","Gio","Ven","Sab","Dom"]*/
   /* date.monthSymbols = ["Gen","Feb","Mar","Apr","Mag","Giu","Lug","Ago","Set","Ott","Nov","Dic"] */
    date.dateStyle = style//.full
   // date.dateFormat = "dd MMMM yyyy"
   // date.timeZone = .autoupdatingCurrent
 //   date.weekdaySymbols = ["Lun","Mar"]
    return (time,date)
    
}
 func csMonthString(from value:Int?) -> String {
    
    guard let value,
     value > 0,
     value < 13 else { return "no value"}
    
    let allMonth = Locale.current.calendar.standaloneMonthSymbols
     
   let current = allMonth[value - 1]
   return current
    
}

func csLastMonthString(from value:Int?,advancedBy:Int?) -> String {
   
   guard let value,
         let advancedBy,
    value > 0,
    value < 13 else { return "no value"}
   
   let newValue:Int = value + advancedBy
   let module = newValue % 12
   let normalized = module == 0 ? 12 : module
    
   let inString = csMonthString(from: normalized)
   return inString
    
}

/// converte una stringa in double sostituendo l'eventuale separtore decimale "," in "."
func csConvertToDotDouble(from string:String) -> Double {
    
    let new = string.replacingOccurrences(of: ",", with: ".")
    let converted = Double(new) ?? 0.0

    return converted

}

/// ritorna una stringa depurata dai caratteri proibiti passati come CharacterSet
func csStringCleaner(value:String,byCharacter forbidden:CharacterSet) -> String {
    
    let step_0 = value.components(separatedBy: forbidden)
    
    let cleanSpace = step_0.filter({$0 != ""})
 
    return cleanSpace.joined(separator: " ")
    
}
