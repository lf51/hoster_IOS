//
//  HOAnnualReportView.swift
//  hoster
//
//  Created by Calogero Friscia on 25/09/24.
//

import SwiftUI
import MyPackView
/// Report confronto performance
struct HOReportPernottamentiView:View {
    
    @EnvironmentObject var viewModel:HOViewModel

    @State var selectedPath:HOInquiryPath = .total
    
    var body: some View {
      
        CSZStackVB(
            title: "Report Pernottamenti",
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
        
        HOReportPernottamentiView()
            .environmentObject(testViewModel)
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



