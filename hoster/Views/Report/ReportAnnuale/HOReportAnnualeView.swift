//
//  HOReportAnnualeView.swift
//  hoster
//
//  Created by Calogero Friscia on 19/10/24.
//

import SwiftUI
import MyPackView

struct HOReportAnnualeView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @State var selected:HOSwitchReport = .area
    
    var body: some View {
      
        CSZStackVB(
            title: "Report Annuale",
            backgroundColorView: Color.hoBackGround) {
                
                VStack(alignment:.leading) {

                    Picker(selection: $selected) {
                        
                        ForEach(HOSwitchReport.allCases,id:\.self) { report in
                            
                            Text("Report per \(report.rawValue.capitalized)")
                               
                            
                        }
                        
                    } label: {
                        //
                    }
                    .tint(Color.cinderella_p47)
                    .pickerStyle(SegmentedPickerStyle())

                    HOAnnualResultView()
                      //  .fixedSize()
                    
                    ScrollView {

                       // HOAnnualResultView()
                        
                        vbSwitchReport()
 
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
    
    // method
    @ViewBuilder private func vbSwitchReport() -> some View {
        
        switch selected {
        case .area:
            HOAnnualAreaReportView()
        case .funzione:
            HOAnnualFunctionReportView()
        }
        
        
    }
   
    
    enum HOSwitchReport:String,CaseIterable {
        
        case area
        case funzione
    }
    
} // chiusa struct

#Preview {
    NavigationStack {
        
        HOReportAnnualeView()
            .environmentObject(testViewModel)
    }
}

struct HOAnnualAreaReportView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    var body: some View {
        
        ForEach(HOAreaAccount.allCases.sorted(by: <),id:\.self) { area in
           // vbGetNastrinoBooks(area: area)
            HONastrinoResumeView(account: area)
        }
    } // chiusa body
    
}

struct HONastrinoResumeView<G:HOProAccountDoubleEntry>:View {

    @EnvironmentObject var viewModel:HOViewModel
    let account:G
    
    @State var openDetails:Bool = true
    
    var body: some View {
        
        let nastrino:HONastrinoAccount? = self.viewModel.getNastrino(for: account, in: nil, for: nil)
        
        VStack(alignment:.leading,spacing: 5) {
    
            HOSubReportView(
                nastrino: nastrino,
                type: nil, cat: nil,
                sub: nil,
                font: .title3,
                fontWeight: .bold,
                opacity: 0.8)
            .padding(.vertical,5)
            .padding(.horizontal,10)
            .background(Color.scooter_p53.gradient.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .onTapGesture {
                withAnimation {
                    self.openDetails.toggle()
                }
            }
         
            if openDetails {
                
                let typeAss = nastrino?.allTypeIn ?? []
                
                ForEach(typeAss.sorted(by: <),id:\.self) { type in
                    
                    HOSubReportView(
                        nastrino: nastrino,
                        type: type,
                        cat: nil,
                        sub: nil,
                        font: .headline,
                        fontWeight: .semibold,
                        opacity: 0.6)
                    
                    let catIn = nastrino?.allCategoryIn ?? []
                    
                    ForEach(catIn.sorted(by: <),id:\.self) { cat in
                        
                        VStack {
                            
                            HOSubReportView(
                                nastrino: nastrino,
                                type: type,
                                cat: cat,
                                sub: nil,
                                font: .callout,
                                fontWeight: .light,
                                opacity: 0.6)
                            
                            let subIn = nastrino?.allSubCategoriesIn ?? []
                            
                            ForEach(subIn.sorted(by: <),id:\.self) { sub in

                                HOSubReportView(
                                    nastrino: nastrino,
                                    type: type,
                                    cat: cat,
                                    sub: sub,
                                    labelOffset: (x: 10, y: 0),
                                    font: .subheadline,
                                    fontWeight: .ultraLight,
                                    opacity:0.6)
                                
                                
                            }
                        }
                        
                    }
                    
                }
            }

        }
        
    }
    
}

struct HOSubReportView:View {
    
  let nastrino:HONastrinoAccount?
    
  let type:HOOperationType?
  let cat:HOObjectCategory?
  let sub:HOObjectSubCategory?
  
  var labelOffset:(x:CGFloat,y:CGFloat) = (x:0,y:0)
    
  let font:Font
  let fontWeight:Font.Weight
  let opacity:Double
    
  var body: some View {
        
       if let value = getResultAndLabel() {
          
           HStack {

                   Text(value.label)
                       .offset(x:labelOffset.x, y:labelOffset.y)
                   
                   Spacer()
                   
                   Text("\(value.result,format: HOAmountUnitMisure.currency)")
               
           }
           .font(font)
           .fontDesign(.monospaced)
           .fontWeight(fontWeight)
           .foregroundStyle(Color.cinderella_p47)
           .opacity(opacity)
           
      }
    }
    
    private func getResultAndLabel() -> (result:Double,label:String)? {
        
        guard let type else {
            
            let result = nastrino?.totalResult ?? 0
            let label = nastrino?.label?.capitalized ?? "Error"
            return (result,label)
        }
        
        guard let result = nastrino?.getResult(throw: type, category: cat, subCategory: sub) else { return nil }
        
        if let sub { return (result,"- \(sub.rawValue)") }
        if let cat { return (result,"- \(cat.rawValue)") }
        else { return (result,type.rawValue.capitalized) }

    }
}

struct HOAnnualFunctionReportView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    var body: some View {
        
        ForEach(HOImputationAccount.allCases.sorted(by: <),id:\.self) { account in
            
           // vbGetNastrinoBooks(account: account)
            HONastrinoResumeView(account: account)
        }
        
    } // chiusa body

}

struct HOAnnualResultView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    @State var openDetails:Bool = false
    
    var body: some View {
 
        VStack(spacing:10) {
                    
                    let risultatoOperativo = self.viewModel.getRisultatoOperativo() ?? (0,0,0,0,0)
                    
                    HStack {
                        
                        Text("Ante Imposte")
                            .foregroundStyle(Color.cinderella_p47)
                           // .opacity(0.8)
                        
                        Spacer()
                        let value = risultatoOperativo.totale
                        
                        Text("\(value,format: .currency(code: self.viewModel.localCurrencyID) )")
                           // .font(.title3)
                            .foregroundStyle(value > 0 ? Color.green : Color.gray)
                        
                    }
                   // .bold()
                    .font(.title2)
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    
                    if openDetails {
                        
                        VStack(spacing:5) {
                            
                            vbDetails(label: "+ Gestione Corrente", value: risultatoOperativo.gestioneCorrente)
                            
                            vbDetails(label: "+ Consumi Magazzino", value: risultatoOperativo.consumoScorte)
                            
                            vbDetails(label: "+ Tributi", value: risultatoOperativo.tasse)
                            
                            vbDetails(label: "+ Ammortamenti", value: risultatoOperativo.ammortamenti)
                            
                        }
                        
                    }
                    

                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
                .background(Color.hoBackGround.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .onTapGesture {
                    
                    withAnimation {
                        self.openDetails.toggle()
                    }
                }

        
    } // method
    
    @ViewBuilder private func vbDetails(label:String,value:Double) -> some View {

            HStack {
                
                Text(label)

                Spacer()
                
                Text("\(value,format: .currency(code: self.viewModel.localCurrencyID))")
                    //.fontWeight(.semibold)
                   
                
            }
            .fontWeight(.light)
            .foregroundStyle(Color.cinderella_p47)
            .font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .opacity(0.8)
        
    }
    
    
}
