//
//  HOUnitCalendarView.swift
//  hoster
//
//  Created by Calogero Friscia on 15/09/24.
//

import SwiftUI
import MyPackView

struct HOMontlyDataView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @State private var mmOrdinale:Int = 1
    @State private var selectedDay:Int?
    
    let focusUnit:String?
    
    var mmReservations:[HOReservation]? { self.viewModel.getReservations(unitRef: focusUnit,notConsiderCheckOut: false) }
    
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

                    HOResumeLineView(
                        mmOrdinale: mmOrdinale,
                        focusUnit: focusUnit)
                    .padding([.top,.trailing],5)
                    .padding(.bottom,10)
                    .padding(.leading,15)
                    .background {
                        
                        Color.hoBackGround
                            .opacity(0.2)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                    
                    HOCalendarGridView(selectedDay: $selectedDay, mmOrdinale: mmOrdinale, focusUnit: focusUnit)
                    
                    if selectedDay != nil {
                        
                        vbInOut()
                        
                    } else {
                        
                        Text("nessun giorno selezionato")
                            .italic()
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    
                    }
                   
                }
                .padding(.horizontal,10)
                .padding(.vertical,10)
            }
            .onAppear(perform: {
                
                self.mmOrdinale = self.viewModel.currentMMOrdinal
                self.selectedDay = self.viewModel.currentDDOrdinal
                
            })
        
    } // chiusa body
    
   /* @ViewBuilder private func vbMMResumeLine() -> some View {
        
        let reservationsInfo = self.viewModel.getReservationInfo(month:self.mmOrdinale,sub: focusUnit)
        
        let count = reservationsInfo?.count ?? 0
        let countString = csSwitchSingolarePlurale(checkNumber: count, wordSingolare: "prenotazione", wordPlurale: "prenotazioni")
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        let gross = reservationsInfo?.grossAmount ?? 0
        let averagePrice:Double = {
            let value = gross / Double(night)
            if value.isNaN { return 0 }
            else { return value }
        }()
        
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
                        .font(.title3)
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
            .lineLimit(1)
            .minimumScaleFactor(0.65)
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
    */
    @ViewBuilder private func vbInOut() -> some View {
        
        let associatedReservation = self.getReservationInOut()
        
        VStack(alignment:.leading,spacing:5) {
            
                if let peopleOuts = associatedReservation.out {
                    
                    ForEach(peopleOuts) { peopleOut in
                        
                        HStack(spacing:5) {

                            Image(systemName: "circle.fill")
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 5))
                            
                            HStack(spacing:3) {
                                
                                Text(peopleOut.guestName ?? "")
                                   
                                Text("is checking out")
                                    .italic()
                            }
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)

                        }
                        
                    }
                    
                } else {
                    
                    HStack(spacing:5) {
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                        
                        Text("no check-out")
                            .italic()
                            .font(.caption)
                            
                    }
                    .foregroundStyle(Color.gray)
                }
 
                if let peopleIn = associatedReservation.in {
                    
                    ForEach(peopleIn) { personIn in
                        
                        VStack(alignment:.leading) {
                            
                            HStack(spacing:5) {
                                
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(Color.green)
                                    .font(.system(size: 5))
                                
                                HStack(spacing:3) {
                                    
                                    Text(personIn.guestName ?? "")
                                        .fontWeight(.semibold)
                                    
                                    Text("is checking in")
                                        .italic()
                                }
                                .font(.caption)
                                .foregroundStyle(Color.cinderella_p47)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                            }
                            
                            vbInOutInfo(for: personIn)
                        }
                        
                    }
                    
                } else {
                    
                    HStack(spacing:5) {
                        
                        Image(systemName: "circle.fill")
                            .foregroundStyle(Color.green)
                            .font(.system(size: 5))
                        
                        Text("no check-in")
                            .italic()
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                }
                
           // }
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
                
              //  Spacer()
            }

            if self.viewModel.isUnitWithSubs,
               let sub = reservation.refUnit,
               focusUnit == nil {
                
                let label = self.viewModel.getUnitModel(from: sub)?.label
                
                HStack(spacing:3) {
                    
                    Image(systemName: "door.right.hand.closed")
                    
                    Text(label ?? "unlabeled")
                        .italic()
                }
                .bold()
                
            }
           // Spacer()
            
            }
        .font(.caption2)
        .foregroundStyle(Color.gray)
        //.opacity(0.8)

        }
   
    @ViewBuilder private func vbMMfilterLine() -> some View {
        
        HStack {
            
            Button(action: {
                
                withAnimation {
                    lessMM()
                }
                
            }, label: {
                Image(systemName: "chevron.backward.circle")
                    .imageScale(.large)
                    .foregroundStyle(Color.hoAccent)
            })
            .opacity(mmOrdinale != 1 ? 1.0 : 0.6)
            .disabled(mmOrdinale == 1)
            
            Spacer()
            
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
                Image(systemName: "chevron.forward.circle")
                    .imageScale(.large)
                    .foregroundStyle(Color.hoAccent)
            })
            .opacity(mmOrdinale != 12 ? 1.0 : 0.6)
            .disabled(mmOrdinale == 12)
           
        }.padding(.horizontal,25)

    }
    
    // method
    
    private func getReservationInOut() -> (in:[HOReservation]?,out:[HOReservation]?) {
        
        guard let mmReservations,
              let selectedDay,
              let localDate = DateComponents(calendar: self.viewModel.localCalendar,year: self.viewModel.yyFetchData, month: self.mmOrdinale, day: selectedDay).date else { return (nil,nil) }
        
        var reservIn:[HOReservation] = []
        var reservOut:[HOReservation] = []
        
        for eachReserv in mmReservations {
            
            guard let ddArrivo = eachReserv.dataArrivo,
                  let ddOut = eachReserv.checkOut else { continue }
            
            if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: ddArrivo) {
                reservIn.append(eachReserv) //= eachReserv
            }
            else if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: ddOut) {
                reservOut.append(eachReserv) //= eachReserv
            }
            
        }
        
        let valueIn:[HOReservation]? = reservIn.isEmpty ? nil : reservIn
        
        let valueOut:[HOReservation]? = reservOut.isEmpty ? nil : reservOut
        
        return (valueIn,valueOut)
    }
    
    private func addMM() {
        
        guard self.mmOrdinale < 12 else { return }
        
        self.mmOrdinale += 1
      //  self.selectedDay = nil
        
    }
    
    private func lessMM() {
        
        guard self.mmOrdinale > 1 else { return }
        
        self.mmOrdinale -= 1
       // self.selectedDay = nil
        
    }
}
/*
#Preview {
    HOUnitCalendarView()
}*/

struct HOCalendarGridView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @Binding var selectedDay:Int?
    let mmOrdinale:Int
    let focusUnit:String?
    
   // var allDateOccupies:[(in:Date,out:Date)]? { viewModel.getOccupancyFor(month: mmOrdinale, unitRef: focusUnit)}
    
    var allDateOccupies:[DateInterval]? { viewModel.getOccupacyInterval(unitRef: focusUnit)}
    
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
        
        for eachInterval in allDateOccupies {
            
            if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: eachInterval.start) {
                pIn = true
                busy = true
            }
            
            else if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: eachInterval.end) { pOut = true }
            
            else if eachInterval.contains(localDate) {
                
                busy = true
            }
            
        }
        
       /* for eachPair in allDateOccupies {
       
            if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: eachPair.in) {
                pIn = true
                busy = true
            }
            else if self.viewModel.localCalendar.isDate(localDate, inSameDayAs: eachPair.out) { pOut = true }
            
            else if localDate > eachPair.in &&
                        localDate < eachPair.out {
                
                busy = true
            }
            
        }*/
      
        return (busy,pIn,pOut,isPassed)
        
    }
    
    
}

