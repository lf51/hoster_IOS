//
//  Untitled.swift
//  hoster
//
//  Created by Calogero Friscia on 21/09/24.
//
import SwiftUI
import MyPackView

struct HOResumeLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let mmOrdinale:Int?
    let focusUnit:String?
    var firstLineFont:Font? = .caption
    var amountFont:(Font,Font)? = (.title3,.title2)
    var subTextFont:Font? = .system(size: 10)
    
    var body: some View {
        
        let reservationsInfo = viewModel.getReservationInfo(month:mmOrdinale,sub: focusUnit)
        
        let count = reservationsInfo?.count ?? 0
        let countString = csSwitchSingolarePlurale(checkNumber: count, wordSingolare: "arrivo", wordPlurale: "arrivi")
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        let gross = reservationsInfo?.grossAmount ?? 0
        let averagePrice:Double = {
            let value = gross / Double(night)
            if value.isNaN { return 0 }
            else { return value }
        }()
        
        
        let tassoDoubleCutted:Double = {
            let tassoOccupazioneNotti = reservationsInfo?.tassoOccupazioneNigh ?? 0
            let tassoCutted = String(format: "%.4f", tassoOccupazioneNotti)
            
            return Double(tassoCutted) ?? 0
        }()

        VStack(alignment:.leading,spacing: 0) {
            
            HStack(spacing:20) {
                
                HStack(spacing:2) {
                    
                    Image(systemName: "person.2.square.stack")
                       
                    Text("\(count) \(countString)")
                }
                
                HStack(spacing:2) {
                    
                    Image(systemName: "person.fill")
                       
                    Text("\(guest)")
                       
                }
                
                Spacer()
                
                HStack(spacing:2){
                    
                    Image(systemName: "moon.zzz.fill")
                       
                    Text("\(night)")
                    
                    Text("(\(tassoDoubleCutted,format: .percent))")
                        .padding(.horizontal,3)
                }
   
            }
            //.fontWeight(.semibold)
            .font(firstLineFont)
            .foregroundStyle(Color.gray)
            
            HStack {
                
                HStack {

                    let label:String = {
                        
                        if mmOrdinale == nil { return "annuale" }
                        else { return "mensile" }
                    }()
                    
                    Text("\(gross,format: .currency(code: viewModel.localCurrencyID))")
                        .font(amountFont?.0)
                        .bold()
                        .foregroundStyle(Color.green)
                    
                    Text(label)
                        .italic()
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                        .offset(x: -10, y: 15)
                    
                }
                Spacer()
                
                HStack {
                    
                    Text("\(averagePrice,format: .currency(code: viewModel.localCurrencyID))")
                        .font(amountFont?.1)
                        .bold()
                        .foregroundStyle(Color.green)
                    
                    Text("notte")
                        .italic()
                        .font(subTextFont)
                        .foregroundStyle(Color.gray)
                        .offset(x: -10, y: 15)

                }
                
                
            }
            .lineLimit(1)
            .minimumScaleFactor(0.65)
        }
        
    }
}

struct HOGrossUnitDataView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    let subs:[HOUnitModel]
    
    var body: some View {

        let mainInfo = viewModel.getReservationInfo(
            month:nil,
            sub: nil)
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.1,
            shadowColor: .black,
            rowColor: Color.scooter_p53,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.leading) {
                    
                   /* Text("Subs (\(subs.count))")
                        .bold()
                        .font(.title)
                        .foregroundStyle(Color.cinderella_p47)
                        .opacity(0.8)*/
                    
                    ForEach(subs,id:\.self) { sub in
                        
                        HOSubReportView(sub: sub,mainInfo: mainInfo)
                        
                        
                    }
                    
                    
                   /* HStack {
                        
                        Text("Totale")
                        
                        Text("\(gross,format: .currency(code: viewModel.localCurrencyID))")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(Color.green)
                        
                    }*/
                    
                    
                    
                }
                .padding(.horizontal,10)
                
            }
        
        
        
    }
}

struct HOSubReportView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let sub:HOUnitModel
    let mainInfo: (count: Int, grossAmount: Double, totaleNotti: Int, totaleGuest: Int, tassoOccupazioneNigh: Double)?
    
    var body: some View {
        
        let localInfo = self.viewModel.getReservationInfo(
            month:nil,
            sub: sub.uid)
        
        VStack(alignment:.leading) {
            
            Text(sub.label)
                .fontDesign(.monospaced)
                .font(.title3)
                .foregroundStyle(Color.cinderella_p47)
                .opacity(0.8)
            
            vbInfoLine(label: "Venduto", value: localInfo?.grossAmount ?? 0, compareTo: mainInfo?.grossAmount ?? 0)
            
            let mainAverage = self.getAveragePrice(gross: mainInfo?.grossAmount ?? 0, night: mainInfo?.totaleNotti ?? 0)
            let localAverage = self.getAveragePrice(gross: localInfo?.grossAmount ?? 0, night: localInfo?.totaleNotti ?? 0)
            
            vbInfoLine(label: "Prezzo Medio", value: localAverage, compareTo: mainAverage)
            
            vbInfoLine(label: "Arrivi", value: Double(localInfo?.count ?? 0), compareTo: Double(mainInfo?.count ?? 0))
            
            vbInfoLine(label: "Guest", value: Double(localInfo?.totaleGuest ?? 0), compareTo: Double(mainInfo?.totaleGuest ?? 0))
            
            vbInfoLine(label: "Notti", value: Double(localInfo?.totaleNotti ?? 0), compareTo: Double(mainInfo?.totaleNotti ?? 0))
            
        }
        
        
    } // chiusa body
    
    private func getAveragePrice(gross:Double,night:Int) -> Double {
        
        let value = gross / Double(night)
        if value.isNaN { return 0 }
        else { return value }
        
    }
    
    @ViewBuilder private func vbInfoLine(label:String,value:Double,compareTo:Double) -> some View {
        
        let incidenza:Double = {
            
            let _0 = value / compareTo
            let _1 = String(format: "%.4f", _0)
            return Double(_1) ?? 0
        }()
        
        HStack {
            
            Text(label)
            
            Spacer()
            
            Text("\(value,format: .number)")
            
            Text("\(incidenza,format: .percent)")
            
            
            
        }
        
        
        
    }
    
}
