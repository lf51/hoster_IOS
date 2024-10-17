//
//  Untitled.swift
//  hoster
//
//  Created by Calogero Friscia on 16/10/24.
//

import SwiftUI

struct HONastrinoResumeLine<IA:HOProAccountDoubleEntry>:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let account:IA
    let mmOrdinal:Int?
    let unitRef:String?
    
    var amountFont:(Font,Font)? = (.title3,.title2)
    var amountColor:(Color,Color)? = (.green,.faluRed_p52)
    var subTextFont:Font? = .system(size: 10)
    var subTextOffset:(x:CGFloat,y:CGFloat) = (5,-5)
    
    let show:HOResumeItem
    
    var body: some View {
        
        HStack {

            let value = self.getLeftAndRight()
            
            VStack(alignment:.trailing,spacing: 0) {

                Text("\(value.left,format: .currency(code: viewModel.localCurrencyID))")
                    .font(amountFont?.0)
                    .bold()
                    .foregroundStyle(amountColor!.0)
                
                Text(value.labelLeft)
                    .italic()
                    .font(subTextFont)
                    .foregroundStyle(Color.gray)
                    .offset(x: subTextOffset.0, y: subTextOffset.1)
                
            }
          //  Spacer()
            
            if let right = value.righ {
 
                Spacer()
                
                VStack(alignment:.trailing,spacing: 0) {

                    Text("\(right,format: .currency(code: viewModel.localCurrencyID))")
                        .font(amountFont?.1)
                        .bold()
                        .foregroundStyle(amountColor!.1)
                    
                    Text(value.labelRight ?? "")
                        .italic()
                        .font(subTextFont)
                        .foregroundStyle(Color.gray)
                        .offset(x: subTextOffset.0, y: subTextOffset.1)

                }
                
            }
            
            
        }
        .lineLimit(1)
        .minimumScaleFactor(0.65)
        
        
    } // chiusa boyd
    
    private func getLeftAndRight() -> (left:Double,labelLeft:String,righ:Double?,labelRight:String?) {
      
        let nastrino = self.viewModel.getNastrino(
            for: account,
            in: mmOrdinal,
            for: unitRef)
        
        var _1value:Double = 0
        var _1label:String = ""
        
        var _2value:Double? = nil
        var _2label:String? = nil
        
        let appendix:String = mmOrdinal == nil ? "annuo" : "mensile"
        
        switch show {
            
        case .total:
            
            let totalResult = nastrino?.totalResult ?? 0
            
            _1value = totalResult
            _1label = "totale \(appendix)"
            
        case .totalPlusAverage:
            
            let totalResult = nastrino?.totalResult ?? 0
           /* let q = nastrino?.qTotal ?? 0
            let averagePrice:Double = {
                let value = totalResult / q
                if value.isNaN { return 0 }
                else { return value }
            }()*/
            let averagePrice:Double = nastrino?.average ?? 0
            
            _1value = totalResult
            _1label = "totale \(appendix)"
            
            _2value = averagePrice
            _2label = "adr"
            
        case .totalPlusQ:
            
            let totalResult = nastrino?.totalResult ?? 0
            let q = nastrino?.qTotal ?? 0
            
            _1value = totalResult
            _1label = "totale \(appendix)"
            
            _2value = q
            _2label = "q total"
            
        case .plusMinus:
            _1value = nastrino?.plusResult ?? 0
            _1label = "plus \(appendix)"
            
            _2value = nastrino?.minusResult ?? 0
            _2label = "minus \(appendix)"
       
        case .plusAndQ:
            
            let plusResult = nastrino?.plusResult ?? 0
            let q = nastrino?.qPlus ?? 0
            
            _1value = plusResult
            _1label = "plus \(appendix)"
            
            _2value = q
            _2label = "q plus"
            
        case .minusAndQ:
            
            let minusResult = nastrino?.minusResult ?? 0
            let q = nastrino?.qMinus ?? 0
            
            _1value = minusResult
            _1label = "minus \(appendix)"
            
            _2value = q
            _2label = "q minus"
            
        case .plus:
            
            let plusResult = nastrino?.plusResult ?? 0
            
            _1value = plusResult
            _1label = "plus \(appendix)"
            
            
        case .minus:
            
            let minusResult = nastrino?.minusResult ?? 0
            
            _1value = minusResult
            _1label = "minus \(appendix)"
        }
        
    
        
        
        return (_1value,_1label,_2value,_2label)
    }
    
    
    enum HOResumeItem {
        
        case total
        case totalPlusQ
        case totalPlusAverage
        case plusMinus
        case plusAndQ
        case minusAndQ
        case plus
        case minus
    }
}
