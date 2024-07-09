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
    
    @Binding var reservation:HOReservation
    
    let generalErrorCheck:Bool
    
    var body: some View {
        
        VStack(alignment:.leading,spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Disposizione (\(self.reservation.disposizione?.count ?? 0))",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "bed.double",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                    CS_ErrorMarkView(
                        warningColor: .hoWarning,
                        scale: .medium,
                        padding: (.trailing,0),
                        generalErrorCheck: generalErrorCheck,
                        localErrorCondition: errorIn())
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
    
    private func errorIn() -> Bool {
        
        guard let dispo = self.reservation.disposizione,
              !dispo.isEmpty else { return true }
        return false
        
    }
    
    private func addBedUnit(type:HOBedType,q:Int) {

        var bedUnits = self.reservation.disposizione ?? []
        
        if bedUnits.first(where: {$0.bedType == type}) != nil {
            bedUnits.removeAll(where: {$0.bedType == type}) }
        
        if q > 0 {
            
            let newUnit = HOBedUnit(bedType: type, number: q)
            bedUnits.append(newUnit)
        }
        
        self.reservation.disposizione = bedUnits

        
    }
}
