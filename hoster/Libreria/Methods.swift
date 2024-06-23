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
