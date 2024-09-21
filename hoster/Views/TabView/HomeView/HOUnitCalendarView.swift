//
//  HOUnitCalendarView.swift
//  hoster
//
//  Created by Calogero Friscia on 15/09/24.
//

import SwiftUI
import MyPackView

struct HOUnitCalendarView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @State private var mmOrdinale:Int = 0
    @State private var selectedDay:Int?
    
    var mmReservations:[HOReservation]? { self.viewModel.getReservations(month: mmOrdinale, unitRef: nil,notConsiderCheckOut: false) }
    
    var body: some View {
            
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.1,
            shadowColor: .black,
            rowColor: Color.scooter_p53,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.leading,spacing: 15) {
                    
                    vbMMfilterLine()
                        
                    vbMMResumeLine()
                    
                    HOUnitCalendarGridView(mmOrdinale: $mmOrdinale, selectedDay: $selectedDay)
                    
                    vbInOut()
                   
                }
                .padding(.horizontal,10)
                .padding(.vertical,10)
            }
            .onAppear(perform: {
                
                self.mmOrdinale = self.viewModel.currentMMOrdinal
                self.selectedDay = self.viewModel.currentDDOrdinal
                
            })
        
    } // chiusa body
    
    @ViewBuilder private func vbMMResumeLine() -> some View {
        
        let reservationsInfo = self.viewModel.getReservationInfo(month:self.mmOrdinale,sub: nil)
        
        let count = reservationsInfo?.count ?? 0
        let countString = csSwitchSingolarePlurale(checkNumber: count, wordSingolare: "prenotazione", wordPlurale: "prenotazioni")
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        let gross = reservationsInfo?.grossAmount ?? 0
        let averagePrice = gross / Double(night)
        
        VStack(alignment:.leading,spacing: 0) {
            
            HStack(spacing:20) {
                
                HStack(spacing:2) {
                    
                    Image(systemName: "person.2.square.stack")
                       
                    Text("\(count) \(countString)")
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
            .fontWeight(.semibold)
            .font(.caption)
            .foregroundStyle(Color.gray)
            
            HStack {
                
                HStack {

                    Text("\(gross,format: .currency(code: self.viewModel.localCurrencyID))")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.green)
                    
                    Text("mensile")
                        .italic()
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                        .offset(x: -10, y: 10)
                    
                }
                Spacer()
                
                HStack {
                    
                    Text("\(averagePrice,format: .currency(code: self.viewModel.localCurrencyID))")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.green)
                    
                    Text("notte")
                        .italic()
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                        .offset(x: -10, y: 10)

                }
                
                
            }
            
        }
        .padding(.vertical,5)
        .padding(.trailing,5)
        .padding(.leading,15)
        
        .background {
            
            Color.hoBackGround
                .opacity(0.2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
        
        
    }
    
    @ViewBuilder private func vbInOut() -> some View {
        
        let associatedReservation = self.getReservationInOut()
        
        VStack(alignment:.leading,spacing:5) {
            
            HStack {
                
                Image(systemName: "circle.fill")
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 5))
                
                if let peopleOut = associatedReservation.out {
                    
                    HStack(spacing:5) {

                        Text(peopleOut.guestName ?? "")
                           
                        Text("is checking out")
                            .italic()

                    }
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                    
                } else {
                    
                    Text("no check-out")
                        .italic()
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                }
            }
            
            HStack(alignment:.center) {
                
                Image(systemName: "circle.fill")
                    .foregroundStyle(Color.green)
                    .font(.system(size: 5))
                
                if let peopleIn = associatedReservation.in {
                    
                    VStack(alignment:.leading) {
                        
                        HStack(spacing:5) {
                            
                            Text(peopleIn.guestName ?? "")
                                .fontWeight(.semibold)
                            
                            Text("is checking in")
                                .italic()
                        }
                        .font(.caption)
                        .foregroundStyle(Color.cinderella_p47)
                        
                        vbInOutInfo(for: peopleIn)
                    }
                    
                } else {
                    
                    Text("no check-in")
                        .italic()
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                }
                
            }
        }
        
    }
    
    @ViewBuilder private func vbInOutInfo(for reservation:HOReservation) -> some View {
        
        HStack(alignment:.lastTextBaseline,spacing: 5) {
            
            HStack(spacing:3) {
                
                let night = reservation.notti ?? 0
                let nights = csSwitchSingolarePlurale(checkNumber: night, wordSingolare: "notte", wordPlurale: "notti")
                
                Image(systemName: "moon.zzz.fill")
                Text("\(night) \(nights)")
                
            }
            
            HStack(spacing:3) {
                
                let pax = reservation.pax ?? 0
                let guest = csSwitchSingolarePlurale(checkNumber: pax, wordSingolare: "guest", wordPlurale: "guests")
                
                Image(systemName: "person.fill")
                
                Text("\(pax) \(guest)")
                
                
            }
         
            HStack(spacing:3) {
                
                let beds = reservation.disposizione ?? []
                
                let bedNumbers = beds.compactMap { $0.number }
                
                let totale = bedNumbers.reduce(into: 0) { partialResult, value in
                    partialResult += value }
                
                let letto = csSwitchSingolarePlurale(checkNumber: totale, wordSingolare: "letto", wordPlurale: "letti")
                
                Image(systemName: "bed.double")
                
                Text("\(totale) \(letto)")
                
                Spacer()
            }
           
            Spacer()
            
            }
        .font(.caption)
        .foregroundStyle(Color.cinderella_p47)
        .opacity(0.8)

        }
   
    @ViewBuilder private func vbMMfilterLine() -> some View {
        
        HStack {
            
            Button(action: {
                
                withAnimation {
                    lessMM()
                }
                
            }, label: {
                Image(systemName: "chevron.compact.backward")
                    .foregroundStyle(Color.hoAccent)
            })
            .opacity(mmOrdinale != 1 ? 1.0 : 0.6)
            .disabled(mmOrdinale == 1)
            
            Spacer()
            
           /* Text(mm)
                .font(.title3)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.cinderella_p47)
              */
            
            
            Picker(selection: $mmOrdinale) {

                ForEach(1...12,id: \.self) { month in
                     
                    let mm = self.viewModel.getMMSymbol(from: month)
                     
                    Text(mm)
                        .fontDesign(.monospaced)
                        .tag(month)
                         
                 }
                 
             } label: {
                 //
             }
             .menuIndicator(.hidden)
             .tint(Color.hoAccent)

            Spacer()
            
            Button(action: {
                withAnimation {
                    addMM()
                }
            }, label: {
                Image(systemName: "chevron.compact.forward")
                    .foregroundStyle(Color.hoAccent)
            })
            .opacity(mmOrdinale != 12 ? 1.0 : 0.6)
            .disabled(mmOrdinale == 12)
           
        }.padding(.horizontal,25)

    }
    
    // method
    
    private func getReservationInOut() -> (in:HOReservation?,out:HOReservation?) {
        
        guard let mmReservations,
              let selectedDay,
              let localDate = DateComponents(calendar: self.viewModel.localCalendar,year: self.viewModel.yyFetchData, month: self.mmOrdinale, day: selectedDay).date else { return (nil,nil) }
        
        var reservIn:HOReservation?
        var reservOut:HOReservation?
        
        for eachReserv in mmReservations {
            
            guard let ddArrivo = eachReserv.dataArrivo else { continue }
            
            if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: ddArrivo) {
                reservIn = eachReserv
            }
            else if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: eachReserv.checkOut) {
                reservOut = eachReserv
            }
            
        }
        
        return (reservIn,reservOut)
    }
    
    private func addMM() {
        
        guard self.mmOrdinale < 12 else { return }
        
        self.mmOrdinale += 1
        self.selectedDay = nil
        
    }
    
    private func lessMM() {
        
        guard self.mmOrdinale > 1 else { return }
        
        self.mmOrdinale -= 1
        self.selectedDay = nil
        
    }
}
/*
#Preview {
    HOUnitCalendarView()
}*/

struct HOUnitCalendarGridView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @Binding var mmOrdinale:Int
    @Binding var selectedDay:Int?
    
    var allDateOccupies:[(in:Date,out:Date)]? { viewModel.getOccupancyFor(month: mmOrdinale, unitRef: nil)}
    
    let columns = [
        GridItem(.flexible(),alignment: .top),
        GridItem(.flexible(),alignment: .top),
        GridItem(.flexible(),alignment: .top),
        GridItem(.flexible(),alignment: .top),
        GridItem(.flexible(),alignment: .top),
        GridItem(.flexible(),alignment: .top),
        GridItem(.flexible(),alignment: .top)
        ]
    
    var body: some View {

        LazyVGrid(
            columns: columns,
            content: {
            
                let days = self.viewModel.getDDGrouped(from: mmOrdinale).sorted(by: {$0.key < $1.key })

                ForEach(days,id:\.key) { key,value in
                    
                    let wdSymbol = self.viewModel.getDDSymbol(from: key)
                    
                    VStack(spacing:5) {
                        
                        Text(wdSymbol)
                            .font(.caption)
                            .foregroundStyle(Color.cinderella_p47)
                            .opacity(0.7)
                            .padding(.bottom,10)
                        
                        ForEach(value,id:\.self) { dd in
                            
                            let occupacyValue = self.getOccupacy(for: dd)
                            let isSelected = selectedDay == dd
                            
                            VStack(spacing:3) {
                                
                                Button {
                                    addSelection(to: dd)
                                } label: {
                                    
                                    Text(dd.description)
                                        .foregroundStyle(Color.black)
                                        .font(.subheadline)
                                        .padding(.vertical,3)

                                }
                                .frame(width:50)
                                .background {
                                    
                                    RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                        .fill(occupacyValue.busy ? Color.brown : Color.cinderella_p47)
                                        .csModifier(isSelected, transform: { backgr in
                                            backgr
                                                .stroke(Color.scooter_p53, lineWidth: 2.5)
                                        })
                                        .opacity(occupacyValue.passed ? 0.4 : 0.8)
                                
                                }
                               
                               // .disabled(disableSelection)

                                HStack(spacing:3) {
                                    
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(occupacyValue.peopleOut ? Color.gray : Color.clear)
                                    
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(occupacyValue.peopleIn ? Color.green : Color.clear)
                                }
                                .font(.system(size: 5))
                                
                                }
                                .csModifier(dd == 0) { dayView in
                                    dayView.hidden()
                                }
                            
                            
                        }
                    }
                }
            })
       
    } // chiusa body
    
    private func addSelection(to dd:Int) {
        
        guard let selectedDay else {
            self.selectedDay = dd
            return
        }
        
        if selectedDay != dd { self.selectedDay = dd }
        else { self.selectedDay = nil }
    }
    
    private func getOccupacy(for day:Int) -> (busy:Bool,peopleIn:Bool,peopleOut:Bool,passed:Bool) {
        
        let localDate = DateComponents(calendar: self.viewModel.localCalendar,year: self.viewModel.yyFetchData, month: self.mmOrdinale, day: day).date
        
        let isPassed:Bool = {
            let dateLocal = localDate ?? Date()
            if self.viewModel.localCalendar.isDateInToday(dateLocal) {
                return false
            } else { return dateLocal.compare(Date()).rawValue == -1 }
            
        }()
        
        guard let allDateOccupies,
              let localDate else { return (false,false,false,isPassed) }
        
        var busy:Bool = false
        var pIn:Bool = false
        var pOut:Bool = false
        
        for eachPair in allDateOccupies {
       
            if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: eachPair.in) {
                pIn = true
                busy = true
            }
            else if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: eachPair.out) { pOut = true }
            
            else if localDate > eachPair.in &&
                        localDate < eachPair.out {
                
                busy = true
            }
            
        }
      
        return (busy,pIn,pOut,isPassed)
        
    }
    
    
}

