//
//  HOHomeView.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView

struct HOHomeView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
   // @State private var yy:Int?
   // @State private var mm:String? // deprecato
    @State private var focusUnit:String?
    
    var body: some View {
        
        NavigationStack(path: $viewModel.homePath) {
            
            let label = viewModel.getWSLabel() //viewModel.getUserName()//viewModel.getWSLabel()
            
            CSZStackVB(
                title: label,
                backgroundColorView: Color.hoBackGround) {
                    
                VStack(alignment:.leading) {
                    
                    vbMainInfoLine()
                        .fixedSize()
                    
                    vbfilterSubLine()
                        .fixedSize()
                    
                    ScrollView {
                        
                        HOGeneralDataView(focusUnit: focusUnit)
                        
                        HOMontlyDataView(focusUnit: focusUnit)
                        
                        
                        
                       // vbReservationResumeLine()
                       // vbPricePerNightResumeLine()
                       // vbCurrentAreaResumeLine()
                      //  vbStockResumeLine()
                       // vbAmmortamentoResumeLine()
                       // vbTributiResumeLine()
                        
                        
                        
                    }.scrollIndicators(.never)
                    
               
                    
                }// vstack madre
                .padding(.horizontal)
                    
            }.navigationDestination(for: HODestinationView.self, destination: { destination in
                destination.destinationAdress(destinationPath: .home, readOnlyViewModel: viewModel)
                })
            .toolbar {
                ToolbarItem(placement:.topBarTrailing) {
                   vbYYfilter()
                   // Text("ciao")
                }
            }
        }// chiusa navStack
       /* .onAppear {
            
            let currentYY = self.viewModel.calendar.component(.year, from: Date())
            self.yy = currentYY
  
        }*/
    } // chiusa body
    
   /* @ViewBuilder private func vbCurrentAreaResumeLine() -> some View {
        
        let reservationsInfo = self.viewModel.getReservationInfo(month:self.mm,sub: self.focusUnit)
        let count = reservationsInfo?.count ?? 0
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        let gross = reservationsInfo?.grossAmount ?? 0
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.2,
            shadowColor: .black,
            rowColor: Color.hoBackGround,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.center,spacing:5) {

                    HStack {
                        
                        Text("Spesa Corrente")
                             .font(.title2)
                             .bold()
                        
                        Spacer()
                        
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.hoAccent)
                        })
                        
                        
                    }
   
                    VStack(alignment:.center) {
                        
                       /* HStack(spacing:20) {
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "person.2.square.stack")
                                   
                                Text("\(count) prenotazioni")
                            }
                            
                            HStack(spacing:2){
                                
                                Image(systemName: "moon.zzz.fill")
                                   
                                Text("\(night)")
                            }
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "person.fill")
                                   
                                Text("\(guest)")
                                   
                            }
                            
                        }
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        */
                        HStack {
                            
                           // Spacer()
                            
                            Text("\(gross,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(Color.green)
                            
                           /* Text("lordo")
                                .italic()
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .offset(x: -10, y: 15)*/
                            
                          //  Spacer()
                        }
                        
                    }
                    
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
            }
        
    }
    
    @ViewBuilder private func vbAmmortamentoResumeLine() -> some View {
        
        let reservationsInfo = self.viewModel.getReservationInfo(month:self.mm,sub: self.focusUnit)
        let count = reservationsInfo?.count ?? 0
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        let gross = reservationsInfo?.grossAmount ?? 0
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.2,
            shadowColor: .black,
            rowColor: Color.hoBackGround,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.center,spacing:5) {

                    HStack {
                        
                        Text("Area Ammortamenti")
                             .font(.title2)
                             .bold()
                        
                        Spacer()
                        
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.hoAccent)
                        })
                        
                        
                    }
   
                    VStack(alignment:.leading) {
                        
                     /*   HStack(spacing:20) {
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "person.2.square.stack")
                                   
                                Text("\(count) prenotazioni")
                            }
                            
                            HStack(spacing:2){
                                
                                Image(systemName: "moon.zzz.fill")
                                   
                                Text("\(night)")
                            }
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "person.fill")
                                   
                                Text("\(guest)")
                                   
                            }
                            
                        }
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        */
                        HStack {
                            
                          //  Spacer()
                            
                            Text("\(gross,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(Color.green)
                            
                          /* Text("lordo")
                                .italic()
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .offset(x: -10, y: 15)
                            
                            Spacer()*/
                        }
                        
                    }
                    
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
            }
        
    }
    
    @ViewBuilder private func vbTributiResumeLine() -> some View {
        
        let reservationsInfo = self.viewModel.getReservationInfo(month:self.mm,sub: self.focusUnit)
        let count = reservationsInfo?.count ?? 0
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        let gross = reservationsInfo?.grossAmount ?? 0
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.2,
            shadowColor: .black,
            rowColor: Color.hoBackGround,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.center,spacing:5) {

                    HStack {
                        
                        Text("Area Tributi")
                             .font(.title2)
                             .bold()
                        
                        Spacer()
                        
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.hoAccent)
                        })
                        
                        
                    }
   
                    VStack(alignment:.leading) {
                        
                      /*  HStack(spacing:20) {
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "person.2.square.stack")
                                   
                                Text("\(count) prenotazioni")
                            }
                            
                            HStack(spacing:2){
                                
                                Image(systemName: "moon.zzz.fill")
                                   
                                Text("\(night)")
                            }
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "person.fill")
                                   
                                Text("\(guest)")
                                   
                            }
                            
                        }
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        */
                        HStack {
                            
                           // Spacer()
                            
                            Text("\(gross,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(Color.green)
                            
                           /* Text("lordo")
                                .italic()
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .offset(x: -10, y: 15)
                            
                            Spacer()*/
                        }
                        
                    }
                    
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
            }
        
    }
    
    @ViewBuilder private func vbStockResumeLine() -> some View {
        
        let wareHouseInfo = self.viewModel.getWarehouseInfo()
        let gross = wareHouseInfo.gross
        let buy = wareHouseInfo.buy
        let consumption = wareHouseInfo.consumo
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.2,
            shadowColor: .black,
            rowColor: Color.hoBackGround,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.leading,spacing:5) {

                    HStack {
                        
                        Text("Scorte Magazzino")
                             .font(.title2)
                             .bold()
                        
                        Spacer()
                        
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.hoAccent)
                        })
                        
                        
                    }
   
                    VStack(alignment:.center) {
                        
                        HStack(spacing:20) {
                            
                            HStack(spacing:2) {
                                

                                Text("IN: \(buy,format: .currency(code: self.viewModel.localCurrencyID))")
                            }
                            
                         //   Spacer()

                            
                            HStack(spacing:2){

                                Text("OUT: \(consumption,format: .currency(code: self.viewModel.localCurrencyID))")
                            }
                            
                            
                            
                        }
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        
                        HStack {
                            
                         //   Spacer()
                            
                            Text("\(gross,format: .currency(code: self.viewModel.localCurrencyID))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(Color.green)
                            
                           /* Text("lordo")
                                .italic()
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .offset(x: -10, y: 15)
                            
                            Spacer()*/
                        }
                        
                     
                    
                        
                        
                    }
                    
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
            }
        
    }
    */
    
   /* @ViewBuilder private func vbPricePerNightResumeLine(value:Double) -> some View {
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.2,
            shadowColor: .black,
            rowColor: Color.hoBackGround,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.leading,spacing:5) {

                    HStack {
                        
                        Text("Vendita Giornaliera Media")
                             .font(.title2)
                             .bold()
                        
                        Spacer()
                        
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.hoAccent)
                        })
                        
                    }

                        HStack {
                            
                            Spacer()
                            
                            Text("\(value,format: .currency(code: self.viewModel.localCurrencyID))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(Color.green)
                            
                            Text("lordo")
                                .italic()
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .offset(x: -10, y: 15)
                            
                            Spacer()
                        }
                        
                    
                    
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
            }
        
    }*/ // deprecato
    
    @ViewBuilder private func vbYYfilter() -> some View {
        
        let dbYY = self.viewModel.getDbStorageYY() ?? []
        
        HStack(spacing:-15) {
         
            Image(systemName: "calendar")
                .padding(.leading,5)
                .imageScale(.large)
                .foregroundStyle(Color.hoDefaultText)
            
            Picker(selection: self.$viewModel.yyFetchData) {
                 
                 ForEach(dbYY,id: \.self) { year in
                     
                     let local = year.description
                     
                     Text(local)
                        // .tag(year as Int?)
                         
                         
                 }
                 
             } label: {
                 //
             }
             .menuIndicator(.hidden)
             .tint(Color.hoDefaultText)
            
        }.background {
             RoundedRectangle(cornerRadius: 5.0)
                 .fill(Color.hoBackGround.opacity(0.4))
         }
        // .tint(Color.hoAccent)
    }
    
    @ViewBuilder private func vbfilterSubLine() -> some View {
        
        let subs:[HOUnitModel]? = self.viewModel.getSubs()
        
        if let subs {
            
            CSZStackVB_Framed(
                frameWidth: 400,
                backgroundOpacity: 0.4,
                shadowColor: .black,
                rowColor: Color.scooter_p53,
                cornerRadius: 5.0,
                riduzioneMainBounds: 20) {
                
                    HStack {
                        
                        Spacer()
                        
                            Picker(selection: $focusUnit) {
                                
                                Text("Struttura Intera")
                                    .tag(nil as String?)
                                
                                ForEach(subs,id: \.self) { sub in
                                    
                                    Text(sub.label)
                                        .tag(sub.uid as String?)
                                        
                                }
                                
                            } label: {
                                //
                            }
                            .menuIndicator(.hidden)
                            .tint(Color.cinderella_p47)
                            
                        Spacer()
                    }
                
            }
            
        }
        
    }
    
    /*@ViewBuilder private func vbReservationResumeLine() -> some View {
        
        let reservationsInfo = self.viewModel.getReservationInfo(month:nil,sub: self.focusUnit)
        let count = reservationsInfo?.count ?? 0
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        let gross = reservationsInfo?.grossAmount ?? 0
        let averagePrice = gross / Double(night)
      // VStack {
            
            CSZStackVB_Framed(
                frameWidth: 400,
                backgroundOpacity: 0.2,
                shadowColor: .black,
                rowColor: Color.hoBackGround,
                cornerRadius: 5.0,
                riduzioneMainBounds: 20) {
                    
                    VStack(alignment:.leading,spacing:5) {

                        HStack {
                            
                            Text("Vendita Pernottamenti")
                                 .font(.title2)
                                 .bold()
                            
                            Spacer()
                            
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "arrow.up.right")
                                    .foregroundStyle(Color.hoAccent)
                            })
                            
                            
                        }
       
                        VStack(alignment:.leading) {
                            
                            HStack(spacing:20) {
                                
                                HStack(spacing:2) {
                                    
                                    Image(systemName: "person.2.square.stack")
                                       
                                    Text("\(count) prenotazioni")
                                }
                                
                                HStack(spacing:2){
                                    
                                    Image(systemName: "moon.zzz.fill")
                                       
                                    Text("\(night)")
                                }
                                
                                HStack(spacing:2) {
                                    
                                    Image(systemName: "person.fill")
                                       
                                    Text("\(guest)")
                                       
                                }
                                
                            }
                            .font(.headline)
                            .foregroundStyle(Color.black)
                            
                            HStack {
                                
                                Spacer()
                                
                                Text("\(gross,format: .currency(code: self.viewModel.localCurrencyID))")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(Color.green)
                                
                                Text("lordo")
                                    .italic()
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    .offset(x: -10, y: 15)
                                
                                Spacer()
                            }
                            
                        }
                        
                    }
                    .padding(.horizontal,10)
                    .padding(.vertical,5)
                }
            
        vbPricePerNightResumeLine(value:averagePrice)
       // }
        
    }*/// deprecato
    
    @ViewBuilder private func vbMainInfoLine() -> some View {
        
        let wsLabel = self.viewModel.getWSLabel()
        let type = self.viewModel.db.currentWorkSpace?.wsType.rawValue() ?? "no value"
        
        let subs = self.viewModel.getSubs()?.count ?? 0
        let ivaSub = self.viewModel.getIvaSubject()
        let paxMax = self.viewModel.getPaxMax()
        let ivaDescr = ivaSub ? "Si" : "No"
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.2,
            shadowColor: .black,
            rowColor: Color.hoBackGround,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.leading,spacing:5) {

                    HStack(alignment:.center,spacing: 2) {
                        
                        Text(wsLabel)
                            .font(.title2)
                            .bold()
                        
                        Text("(\(type))")
                            .italic()
                            .font(.caption2)
                        
                        Spacer()
                        
                        Button(action: {
                            
                            self.viewModel.addToThePath(destinationPath: .home, destinationView: .setupWsData)
                            
                        }, label: {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.hoAccent)
                        })
                        

                    }
                    
                    HStack(spacing:10) {
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "house.fill")
                                    .foregroundStyle(Color.scooter_p53)
                                Text("sub: \(subs)")
                                
                            }
                            
                        //    Text("•")
                            
                            HStack(spacing:2) {
                                
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color.scooter_p53)
                                Text("max: \(paxMax)")
                            }
                            
                        HStack(spacing:2) {
                            
                            Image(systemName: "person.text.rectangle.fill")
                                .foregroundStyle(Color.scooter_p53)
                            Text("p.ta IVA: \(ivaDescr)")
                            
                        }
                        
                        
                        }
                        .font(.headline)
                        
                       /* Text(ivaDescr)
                            .italic()
                            .font(.caption)
                            .fontWeight(.light)*/
                    

                    vbCheckInOut()
                    
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
               
            }
        
    }
    
    @ViewBuilder private func vbCheckInOut() -> some View {
        
        let checkIn = self.viewModel.getCheckInTime()
        let checkOut = self.viewModel.getCheckOutTime()
        
        let timeIn:String = csTimeString(from: checkIn.hour, minute: checkIn.minute)
        let timeOut:String = csTimeString(from: checkOut.hour, minute: checkOut.minute)
 
        let symbol:(am:String,pm:String) = {
            
            let calendar = Locale.current.calendar
            return (calendar.amSymbol,calendar.pmSymbol)
            
        }()
        
        HStack(spacing:15) {

            HStack(spacing:2) {
                Image(systemName: "arrowshape.down.fill")
                    .foregroundStyle(Color.faluRed_p52)
                Text("\(timeOut) \(symbol.am.lowercased())")
                
            }
 
            HStack(spacing:2) {

                Image(systemName: "arrowshape.up.fill")
                    .foregroundStyle(Color.green)
                
                Text("\(timeIn) \(symbol.pm.lowercased())")
                
            }
            
        }.font(.headline)
        
    }
}

#Preview {
    HOHomeView()
        .environmentObject(testViewModel)
}



