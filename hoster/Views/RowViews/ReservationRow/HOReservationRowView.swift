//
//  HOReservationRowView.swift
//  hoster
//
//  Created by Calogero Friscia on 29/07/24.
//

import SwiftUI
import MyPackView

struct HOReservationRowView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let reservation:HOReservation
    
    @State private var openOperationsDetail:Bool = false
    
    var body: some View {
        
        VStack(spacing:2) {
            
            CSZStackVB_Framed() {
                
                VStack(alignment:.leading,spacing: 10) {
                    
                    vbFirstLine()
                    
                    VStack(alignment:.leading,spacing:5) {
                        
                        vbSecondLine()
                        vbThirdLine()
                        vbFiveLine()
                    }
                   
                    // note
                    
                } // chiusa vstack madre
                .padding(.horizontal,10)
                .padding(.vertical,5)
            }// chiusa framed
            .overlay(alignment: .bottomTrailing) {
                
                HStack(spacing:30) {
                    
                    vbOverlayButton()
                    
                    Menu {
                        self.reservation.vbInteractiveMenu(viewModel: self.viewModel)
                    } label: {
                        
                        Image(systemName:"gearshape")
                            .imageScale(.large)
                            .foregroundStyle(Color.hoDefaultText)
                            .padding(5)
                            .background {
                                Color.hoBackGround.opacity(0.5)
                                    .clipShape(Circle())
                                    .shadow(radius: 5.0)
                            }

                    }
                }
            }
            
            if openOperationsDetail {
                
                vbOperationDetails()
                    .onTapGesture {
                        withAnimation {
                            self.openOperationsDetail = false
                        }
                    }
            }
        }
        
        
    } // chiusa body
    
    private func getValues() -> (optSorted:[HOOperationUnit],net:String,cityTax:HOOperationUnit?)? {
        
        guard let optsRef = self.reservation.refOperations,
              let opts = self.viewModel.getOperation(from: optsRef) else { return nil }
        
        let cityTax = opts.first(where: {$0.writing?.oggetto?.getSubCategoryCase() == .cityTax })
        
        let opts_1 = opts.filter({$0.writing?.oggetto?.getSubCategoryCase() != .cityTax })
        
        let opts_1Ref = opts_1.map({$0.uid})
        
        let net = self.viewModel.getEconomicResult(from: opts_1Ref)
        let netString = net.formatted(.currency(code: self.viewModel.localCurrencyID))
        
        let opts_1Sorted = opts_1.sorted(by: { ($0.amount?.imponibile ?? 0) > ($1.amount?.imponibile ?? 0) })
        
        return (opts_1Sorted,netString,cityTax)
        
    }
    
    @ViewBuilder private func vbOperationDetails() -> some View {
        
        if let optValue = self.getValues() {
            
            CSZStackVB_Framed(backgroundOpacity:0.15) {
            
                Grid(verticalSpacing: 5) {
                    
                    HStack {
                        
                        Text("Detail")
                            .bold()
                            .font(.title3)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                   
                    ForEach(optValue.optSorted) { opt in
                        
                        let label = opt.writing?.oggetto?.getDescription(campi: \.category,\.subCategory)
                        let cost = opt.amount?.imponibileStringValue ?? "0.00 €"
                        let signColor = opt.writing?.type?.getColorAssociated() ?? Color.gray
                        
                        GridRow {
                            
                            Text(label ?? "no label")
                                .foregroundStyle(Color.black)
                                .gridColumnAlignment(.leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
  
                            Spacer()
                            
                            Text(cost)
                                .fontWeight(.semibold)
                                .foregroundStyle(signColor)
                                .gridColumnAlignment(.trailing)


                        }
                        .kerning(-1)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                      
                    }

                    GridRow {
                        
                        Text("Netto")
                            .foregroundStyle(Color.cinderella_p47)
      
                        Spacer()
                        
                        Text(optValue.net)
                            .bold()
                            .foregroundStyle(Color.scooter_p53)

                           
                    }
                    .kerning(-1)
                    .font(.title3)
                    .fontDesign(.monospaced)
                  
                    
                    GridRow {
                        
                        let label = optValue.cityTax?.writing?.oggetto?.getDescription(campi:\.subCategory) ?? "city tax"
                        let cost = optValue.cityTax?.amount?.imponibileStringValue ?? "0.00 €"
             
                        Text(label)
                            .foregroundStyle(Color.gray)
                       
                        Spacer()

                        Text(cost)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.gray)
                        
                    }
                    .italic()
                    .kerning(-1)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
                
            }
            
            
        } else {
            
            CSZStackVB_Framed(backgroundOpacity:0.25) {
                
                Text("nessuna operazione associata")
                    .italic()
                    .padding(.leading,10)
            }
        }

    }
    
    @ViewBuilder private func vbOverlayButton() -> some View {
        
        let image:String = {
            
            if self.openOperationsDetail {
                return "chevron.compact.up"
            } else {
                return "chevron.compact.down"
            }
        }()
    
        Button(action: {
            withAnimation {
                self.openOperationsDetail.toggle()
            }
            
        }, label: {
            Image(systemName: image)
                .bold()
                .imageScale(.large)
                .foregroundStyle(Color.hoAccent)
        })

    }
    
    @ViewBuilder private func vbFiveLine() -> some View {
        
        let refUnit = reservation.refUnit ?? ""
        let subs = self.viewModel.getSubs()
        let unit = subs?.first(where: {$0.uid == refUnit})
        
        let unitName = unit?.label ?? "main"
        
        CSEtichetta(
            text: unitName,
            fontStyle: .headline,
            fontWeight: .light,
            fontDesign: .rounded,
            textColor: Color.black,
            image: "house",
            imageColor: Color.black,
            imageSize: .medium,
            backgroundColor: Color.gray,
            backgroundOpacity: 0.2)
        
    }
    
    @ViewBuilder private func vbFourthLine() -> some View {
        
            let portale = self.reservation.labelPortale ?? "no OTA"
            
            Text(portale)
                .italic()
                .bold()
                .font(.subheadline)
                .foregroundStyle(Color.gray)

    }
    
    @ViewBuilder private func vbThirdLine() -> some View {
        
        HStack(alignment:.lastTextBaseline,spacing: 15) {
            
            HStack(spacing:3) {
                
                let night = self.reservation.notti ?? 0
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
                
                let beds = self.reservation.disposizione ?? []
                
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
        .font(.subheadline)
        .foregroundStyle(Color.black)
        .opacity(0.8)

        }
        
    
    @ViewBuilder private func vbSecondLine() -> some View {
        
        let checkOut = csTimeFormatter(style: .medium).data.string(from: self.reservation.checkOut)
       
        let checkIn = csTimeFormatter(style: .medium).data.string(from: self.reservation.dataArrivo ?? Date())
        
        HStack {
            
            Image(systemName: "calendar")
            
            Text("\(checkIn) - \(checkOut)")
            
            Spacer()
        }
        .font(.subheadline)
        .foregroundStyle(Color.black)
        
    }
    
    @ViewBuilder private func vbFirstLine() -> some View {
        
        VStack(alignment:.leading,spacing: 0) {
            
            HStack {
                
                Text(self.reservation.guestName ?? "no guest")
                    .font(.title)
                    .kerning(-3)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                vbVisualSchedule(reservation: reservation, viewModel: viewModel)
     
            }
            
            vbFourthLine()
            
        }//.padding(.bottom,5)
        
    }
}
