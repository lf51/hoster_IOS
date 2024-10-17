//
//  HOAnnualReportView.swift
//  hoster
//
//  Created by Calogero Friscia on 25/09/24.
//

import SwiftUI
import MyPackView
/// Report confronto performance
struct HOAnnualReportView:View {
    
    @EnvironmentObject var viewModel:HOViewModel

    @State var selectedPath:HOInquiryPath = .total
    
    var body: some View {
      
        CSZStackVB(
            title: "Report \(self.viewModel.yyFetchData)",
            backgroundColorView: Color.hoBackGround) {
                
                VStack(alignment:.leading) {
                    
                    let mainValue = self.selectedPath.getInquiryValue(for: nil, subUid: nil, viewModel: self.viewModel)
                  
                    HOReservationsResumeLineView(
                        mmOrdinale: nil,
                        focusUnit: nil,
                        firstLineFont: .headline)
               
                    
                    HStack {
                        
                        Picker(selection: $selectedPath) {
                            
                            ForEach(HOInquiryPath.allCases,id:\.self) { value in
                                
                                Text(value.rawValue)
                                    .tag(value)
                                
                            }
                            
                        } label: {
                            //
                        }
                        .tint(Color.hoAccent)
                        .menuIndicator(.hidden)
                       // .buttonBorderShape(.roundedRectangle)
                        .background {
                            Color.hoBackGround
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                        Spacer()
                        
                        Text("\(mainValue,format:selectedPath.getUnitMisureAssociated())")
                            .bold()
                            .font(.title)
                            .foregroundStyle(Color.cinderella_p47)
                        
                    }

                    
                    ScrollView {
                        
                        if let subs = self.viewModel.getSubs() {
                            
                            VStack(alignment:.leading) {
                                
                                Text("Performance Sub Units")
                                    .font(.subheadline)
                                    .fontDesign(.monospaced)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.gray)
                                
                                HOSubsReportLineView(
                                    subs: subs,
                                    mainValue: mainValue,
                                    inquiryPath: selectedPath)
                            }
                            
                            
                        }
                        
                      //  Divider()
                            
                        VStack(alignment:.leading) {
                            
                            Text("Performance Mensile")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.gray)
                            
                            HOMonthlyReportLineView(
                                mainValue:mainValue,
                                inquiryPath:selectedPath)
                        }
                        
                      
           
                        
                    }// chiusa Scroll
                    .scrollIndicators(.never)
                  

                }// chiusa VStack Madre
                .padding(.horizontal,10)
                
                
            }// chiusa ZStackFramed
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    vbCurrentYearView(viewModel: self.viewModel)

                }
            }
        
    } // chiusa body
}

#Preview {
    NavigationStack {
        
        HOAnnualReportView()
            .environmentObject(testViewModel)
    }
}

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

struct HOSubsReportLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let subs:[HOUnitModel]
    let mainValue:Double
    let inquiryPath:HOInquiryPath
    
    var body: some View {

        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
            
            let subEnumerate = Array(subs.enumerated())
            
            ForEach(subEnumerate,id:\.offset) { index,sub in
                
                HOReportGridRow(
                    mainValue: mainValue,
                    inquiryPath: inquiryPath,
                    position: index,
                    label: sub.label,
                    mmOrdinal: nil,
                    subUid: sub.uid)
                .font(.subheadline)
            }
  
        }
        
    }
}

struct HOMonthlyReportLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let mainValue:Double
    let inquiryPath:HOInquiryPath
    
    var body: some View {

        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
            
            ForEach(self.viewModel.localCalendarMMRange,id:\.self) { mm in

                let month = self.viewModel.getMMSymbol2(from: mm)
                let ordinal = self.viewModel.getMMOrdinal(from: mm)
                
                HOReportGridRow(
                    mainValue: mainValue,
                    inquiryPath: inquiryPath,
                    position: ordinal,
                    label: month,
                    mmOrdinal: ordinal,
                    subUid: nil)
                .font(.subheadline)
            }
  
        }
        
    }
    
}

struct HOReportGridRow:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let mainValue:Double
    let inquiryPath:HOInquiryPath
    
    let position:Int
    let label:String
    
    let mmOrdinal:Int?
    let subUid:String?
    
    var body: some View {
        
        GridRow {
            
            let value = self.getRelatedValue(in:mmOrdinal,for: subUid)
            
            Text("\(position)")
                .frame(width: 25, height: 17)
                //.font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.cinderella_p47)
                .background(Color.hoBackGround)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Text(label)
                .fontWeight(.semibold)
               // .font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.cinderella_p47)
                .fixedSize()
                
           RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.gray)
                .opacity(0.2)
                .frame(width:100,height: 5)
                .overlay(alignment:.leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(value.barraColor.gradient)
                        .frame(width:value.barra,height: 5)
                }
            
            Text("\(value.incidenza,format: .percent)")
                .font(.caption2)
                .foregroundStyle(Color.gray)
            
            Spacer()

            Text("\(value.local,format:inquiryPath.getUnitMisureAssociated())")
                .fontWeight(.bold)
                .foregroundStyle(Color.scooter_p53)
                .gridColumnAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

              
        }
        
    } // chiusa body
    
    private func getRelatedValue(in monthOrdinal:Int?,for subUid:String?) -> (local:Double,incidenza:Double,barra:CGFloat,barraColor:Color) {

        let value = self.inquiryPath.getInquiryValue(for: monthOrdinal,subUid: subUid, viewModel: self.viewModel)
        
        let incidenza:Double = {
            
            let start = value / mainValue
            let step_2 =  String(format: "%.3f", start)
            return Double(step_2) ?? 0
        }()
        
        let barra:Double = {
            
            let start = 100 * incidenza
            
            if start > 100 { return 100 }
            else if start < 0 { return 0 }
            else if start.isNaN { return 0 }
            
            return start
        }()
        
        let colorBarra:Color = {
            
            switch incidenza {
            case 0..<0.25: return Color.red
                
            case 0.25..<0.75: return Color.orange
                
            case 0.75..<1.0: return Color.yellow
                
            default: return Color.green
            }
            
            
        }()
        
        return (value,incidenza,barra,colorBarra)
    }
}
