//
//  HOBedDispoLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 06/05/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOBedDispoLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
   // @Binding var reservation:HOReservation
    @ObservedObject var builderVM:HONewReservationBuilderVM
    
    let generalErrorCheck:Bool
    
    
    var body: some View {
        
        VStack(alignment:.leading,spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Disposizione (\(self.builderVM.reservation.disposizione?.count ?? 0))",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "bed.double",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                    HStack {
                        
                        CS_ErrorMarkView(
                            warningColor: .hoWarning,
                            scale: .medium,
                            padding: (.trailing,0),
                            generalErrorCheck: generalErrorCheck,
                            localErrorCondition: !self.builderVM.checkDispo())
                        
                        Spacer()
                        
                        if !builderVM.paxIsConformToBeds {
                            
                            Button(action: {
                                
                                self.viewModel.sendAlertMessage(alert: AlertModel(title: "Attenzione", message: "Il numero di ospiti eccede il numero max per le unità letto. Correggere o ignorare."))
                                
                            }, label: {
                                Image(systemName: "lightbulb.min.badge.exclamationmark.fill")
                                    .imageScale(.medium)
                                    .foregroundStyle(Color.yellow)
                            })
                            
                        }
                        
                    }
                }
            
            VStack(alignment:.leading) {
                
                let bedTypeIn = self.viewModel.getBedTypeIn()
                
                ForEach(bedTypeIn,id:\.self) { type in
                    
                    let label = type.getStringValue().capitalized
                    
                        CSSinkStepper_1(
                            range: 0...20,
                            label: label,
                            labelText: Color.hoDefaultText,
                            labelBackground: Color.scooter_p53,
                            image: "bed.double.fill",
                            imageColor: Color.hoAccent,
                            valueColor:Color.hoDefaultText,
                            numberWidth: 35) { _, new in
                                
                                addBedUnit(type: type, q: new)
                                
                            }
                           
                }
            }
        }
    }
    
    private func addBedUnit(type:HOBedType,q:Int) {

        var bedUnits = self.builderVM.reservation.disposizione ?? []
        
        if bedUnits.first(where: {$0.bedType == type}) != nil {
            bedUnits.removeAll(where: {$0.bedType == type}) }
        
        if q > 0 {
            
            let newUnit = HOBedUnit(bedType: type, number: q)
            bedUnits.append(newUnit)
        }
        
        self.builderVM.reservation.disposizione = bedUnits

        
    }
}
