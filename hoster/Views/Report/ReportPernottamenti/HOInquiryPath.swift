//
//  Untitled.swift
//  hoster
//
//  Created by Calogero Friscia on 19/10/24.
//

enum HOInquiryPath:String,CaseIterable {
    
    case total = "revenue"
    case adr
    case guestAverage = "occupazione media"
    case nightAverage = "pernottamento medio"
    
    func getUnitMisureAssociated() -> HOAmountUnitMisure {
        
        switch self {
        case .total,.adr:
            return .currency

        case .guestAverage:
            return .pax
        case .nightAverage:
            return .night
        }
        
    }
    
    func getNastrinoPath() -> KeyPath<HONastrinoAccount,Double>? {
        
        switch self {
            
        case .adr:
            return \.average
            
        case .total:
            return \.totalResult
            
        case .guestAverage,.nightAverage: return nil
        }
    }
    
    func getInquiryValue(for monthOrdinal:Int?,subUid:String?,viewModel:HOViewModel) -> Double {

       var finalValue:Double = 0
        
       if let path = self.getNastrinoPath() {
           
           let nastrino = viewModel.getNastrino(for: HOImputationAccount.pernottamento, in: monthOrdinal, for: subUid)
           
           let value = nastrino?[keyPath: path] ?? 0
           finalValue = value
           
       } else  {
           
           let localInfo = viewModel.getReservationInfo(month: monthOrdinal, sub: subUid)
           
           guard let baseValue = localInfo?.count else { return 0 }
           
           let doubleBase = Double(baseValue)
          // var value:Double = 0
           
           switch self {
           
           case .guestAverage:
               
               let guest = localInfo?.totaleGuest ?? 0
               let doubleGuest = Double(guest)
               
               finalValue = doubleGuest / doubleBase
               
           case .nightAverage:
               
               let nights = localInfo?.totaleNotti ?? 0
               let doubleNight = Double(nights)
               
               finalValue = doubleNight / doubleBase
               
           default: return 0
           }

       }
        
        if finalValue.isNaN { return 0 }
        else if finalValue.isInfinite { return 0 }
        else {
            
            let valueNormalize:Double = {
                
                let step_2 =  String(format: "%.2f", finalValue)
                return Double(step_2) ?? 0
            }()
            
            return valueNormalize
            
        }
   }
}
