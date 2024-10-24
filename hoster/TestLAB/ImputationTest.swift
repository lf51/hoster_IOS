//
//  ImputationTest.swift
//  hoster
//
//  Created by Calogero Friscia on 29/03/24.
//

import SwiftUI


struct LazyContentView: View {
    
    let money:Double = 10000
    let dividend:Double = 3
    var body: some View {
        
        VStack {
            
            Text("\(money,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
            
            Text("\(money,format:HOAmountUnitMisure.currency)")
            
            let x = money/dividend
            Divider()
            
            Text("\(x,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
            
            Text("\(x,format:HOAmountUnitMisure.currency)")
            
            
            Text("\(x,format:HOAmountUnitMisure.percent)")
            
            Text("\(x,format:HOAmountUnitMisure.pax)")
            
            Text("\(x,format:HOAmountUnitMisure.hour)")
            
            Text("\(x,format:HOAmountUnitMisure.year)")
            Text("\(x,format:HOAmountUnitMisure.pernottamenti)")
            Text("\(x,format:HOAmountUnitMisure.pernottamenti)")
            Text("\(x,format:HOAmountUnitMisure.mc)")
            Text("\(x,format:HOAmountUnitMisure.kw)")
            
            Text("\(x,format:HOAmountUnitMisure.kw)")
            
        }
    }
}

#Preview {
    LazyContentView()
}
