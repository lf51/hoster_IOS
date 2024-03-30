//
//  SetWorkSpaceView.swift
//  hoster
//
//  Created by Calogero Friscia on 06/03/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOViewSetWorkSpace: View {
   
    @EnvironmentObject var viewModel:HOViewModel
    @ObservedObject var authManager:HOAuthManager
    let backgroundColor:Color
    
    @State private var workSpace:WorkSpaceModel = WorkSpaceModel()
    @State private var generalErrorCheck:Bool = false
    
    var body: some View {
        
        CSZStackVB(
            title: "Create a WorkSpace",
            titlePosition: .bodyEmbed(.horizontal, 10),
            backgroundColorView: backgroundColor) {
            
                VStack(spacing:10) {
                    
                    Image(systemName: "building.2")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.seaTurtle_1)
                        .frame(maxHeight:150)
                        .padding(.vertical,30)
                        .fixedSize(horizontal: false, vertical: true)
                  //  Spacer()
                    
                    VStack(alignment:.leading) {
                        
                        HStack {
                            
                            vbType()
                            
                            CSTextField_1(
                                text: $workSpace.wsUnit.main.label,
                                placeholder: "nome del workSpace",
                                symbolName: self.workSpace.wsType.systemImage(),
                                symbolColor: .white,
                                backgroundColor: .lightGray,
                                cornerRadius: 15,
                                keyboardType: .default)
                            
                        }
                        .padding(.top,10 )
                        
                        Text("WorkSpace type: \(self.workSpace.wsType.rawDescription())\nAllUnits:\(self.workSpace.wsUnit.all.count)")
                            .italic()
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundStyle(Color.black)
                            .opacity(0.6)
                        
                        Divider()
              
                            vbUnitBuilder()
            
                    }

                    Spacer()
                    
                  CSBottomDialogView(
                    primaryButtonTitle: "Submit",
                    secondaryButtonTitle: "Delete Account")  {
                        description()
                    } disableConditions: {
                        disableCondition()
                    } secondaryAction: {
                        secondaryAction()
                    } preDialogCheck: {
                        preDialogCheck()
                    } primaryDialogAction: {
                        primaryDialogAction()
                        
                    }

                    
                }
            
        }
        
    }
    
    // Method MyDialogViewPack
    
    func description() -> (Text, Text) {
        
        let maxPax = self.workSpace.paxMax
        let typeString = self.workSpace.wsType.rawValue()
   
        let subs = self.workSpace.wsUnit.subs?.count ?? 0
        let subDescr = subs == 0 ? "" : "\nSubs: \(subs)"
        
        let breve = "Type: \(typeString)\(subDescr)\nMax person in: \(maxPax)"
        
        // estesa
        
        let wslabel = self.workSpace.wsLabel
        
        let estesa = "\(wslabel)\nType: \(typeString)\(subDescr)\nCapienza Massima: \(maxPax)"
        
        
        return (Text(breve),Text(estesa))
    }
    
    func disableCondition() -> (Bool?, Bool, Bool?) {
        
        let conditionOne = self.workSpace.wsUnit.main.label.isEmpty
        let conditionTwo:Bool = self.workSpace.paxMax == 0
        let finalCondition = conditionOne || conditionTwo
        
        return (nil,finalCondition,nil)
    }
    
    func secondaryAction() {
        self.authManager.eliminaAccount()
    }
    
    func preDialogCheck() -> Bool {
        
        guard let subUnits = workSpace.wsUnit.subs else {
            // per l'unità intera basta la logica del disabilita
            return true
        }
        
        let subsCount = subUnits.count
        
        let labelsOk = subUnits.map({$0.label})
        let reduceLabs = labelsOk.reduce(into:0) { partialResult, label in
            
            partialResult += (label.isEmpty) ? 0 : 1
        }
        
        let firstCondition = reduceLabs == subsCount
        
        guard firstCondition else {
            self.generalErrorCheck = true
            return false
        }
        
        let subsOk = subUnits.map({$0.pax ?? 0})
        let reduceSubs = subsOk.reduce(into: 0) { partialResult, value in
            
            partialResult += (value > 0) ? 1 : 0
        }
        
        let conditionTwo = reduceSubs == subsCount
        self.generalErrorCheck = !conditionTwo
        return conditionTwo
      
    }
    
    @ViewBuilder func primaryDialogAction() -> some View {
        
        csBuilderDialogButton {
            
            DialogButtonElement(
                label: .saveAndGo,
                extraLabel: nil,
                role: nil) {
                    true
                } action: {
                    // salva utente su firebase first time
                    self.viewModel.firstRegOnFirebaseAfterAuth(first: self.workSpace)
 
                }

        }
    }
    
    @ViewBuilder private func vbType() -> some View {
           
            Menu {
                
                ForEach(WorkSpaceType.allCases,id:\.self) { type in
                    
                    Button(action: {

                        withAnimation {
                            self.setUnitType(value: type)
                        }
                        
                    }, label: {

                            Text(type.rawValue())
                            Image(systemName: type.systemImage())
                    })
                }

            } label: {
                Image(systemName: self.workSpace.wsType.systemImage())
                    .foregroundStyle(Color.white)
                    .imageScale(.large)
                    .padding(12)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 16,style: .circular))
                    .shadow(radius: 2)
                    
            }

    }
    
    private func setUnitType(value:WorkSpaceType) {
        // 11.03.24 abbiamo abolito il setter nella unit Type preferendo un setter dinamico da compilare quando necessario. Lo mettiamo qui, perchè questo è per la fase di creazione e non ci serve in altre circostante. Preferiamo evitare il rischio di utilizzare un setter nella computed con una logica che può creare bug in altre circostanze. Se in futuro prevederemo di passare da un type ad un altro a workspace creato avremmo la necessità di un setter specifico differente da questo
        
        switch value {
        case .wholeUnit:
           
            self.workSpace.wsUnit.subs = nil
           // self.workSpace.allUnits = [self.workSpace.mainUnit]
          
        case .withSub:
            let firstSub = HOUnitModel(type: .sub)
            self.workSpace.wsUnit.main.pax = nil
            self.workSpace.wsUnit.subs = [firstSub]
           
        }
        
    }
    
    @ViewBuilder private func vbUnitBuilder() -> some View {
        
        let type = self.workSpace.wsType
        
        switch type {
        case .withSub:
            vbSubUnit()
        case .wholeUnit:
            vbWholeUnit()
        }
        
    }
    
    @ViewBuilder private func vbWholeUnit() -> some View {
        
        let pax = self.workSpace.paxMax
    
            HStack {
            
                CSSinkStepper_1(
                    range:0...20,
                    image:"person.2.fill",
                    imageColor:Color.gray) { _, newValue in
                    
                        self.workSpace.wsUnit.main.pax = newValue
   
                }
                .fixedSize()
                
                let personValue = csSwitchSingolarePlurale(checkNumber:pax, wordSingolare: "person", wordPlurale: "persons")
                
                Text("max \(pax) \(personValue) in")
                    .font(.caption)
                    .fontWeight(.light)
                    .italic()
                    .foregroundStyle(Color.black)
                    .opacity(0.6)
                
                Spacer()

            }
            
    }
    
    @ViewBuilder private func vbSubUnit() -> some View {
    
        let subs = Binding {
            self.workSpace.wsUnit.subs ?? []
        } set: { newValue in
            self.workSpace.wsUnit.subs = newValue
        }

        let enumeratedSubs = Array(subs.enumerated())
        
        VStack(alignment:.leading) {
            
            CSLabel_conVB(
                placeHolder: "SubUnits",
                imageNameOrEmojy: "building.2",
                imageColor: nil,
                backgroundColor: Color.black) {
                    
                    HStack {
                        
                        Button(action: {
                            
                            withAnimation {
                                addUnit()
                            }
                            
                        }, label: {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                        })
                        
                        let disable = subs.wrappedValue.count <= 1
                        
                        Button(action: {
                            
                            withAnimation {
                                delUnit()
                            }
                            
                        }, label: {
                            Image(systemName: "minus.circle")
                                .imageScale(.large)
                                .foregroundStyle(Color.red)
                        })
                        .opacity(disable ? 0.2 : 1.0)
                        .disabled(disable)
                    }
                    
                }
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    ForEach(enumeratedSubs,id:\.offset) { position, sub in
                            
                        RowSetUnitModelView(
                            unit: sub,
                            position: position, 
                            generalCheck: generalErrorCheck)
                    
                            
                        }
                }
            }
        }
    }
    
    private func addUnit() { 
        
        let newUnit = HOUnitModel(type: .sub)
        self.workSpace.wsUnit.subs?.append(newUnit)
    }
    
    private func delUnit() { 
        
        guard var subUnits = workSpace.wsUnit.subs else { return }
        
        guard subUnits.count > 1 else { return }
        
        subUnits.removeLast()
        self.workSpace.wsUnit.subs = subUnits
    }
}

#Preview {
    HOViewSetWorkSpace(
        authManager: HOAuthManager(),
        backgroundColor: Color.yellow.opacity(0.9))
}

struct RowSetUnitModelView:View {

   @Binding var unit:HOUnitModel
   let position:Int
   let generalCheck:Bool
    
    var body: some View {
        
            HStack(spacing:5) {

                HStack {
                    
                    Text("\(position + 1)")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.white)
                        .padding(.leading,5)
                        
                    TextField("sub label",text: self.$unit.label)
                        .padding(5)
                }
                .background {
                    Color.gray.opacity(0.2)
                }
                    .clipShape(RoundedRectangle(cornerRadius: 5,style: .continuous))

                CSSinkStepper_1(
                    range: 0...20,
                    image:"person") { _, newValue in
                    self.unit.pax = newValue
                }
                .fixedSize()
                .csWarningModifier(warningColor:Color.blue,overlayAlign:.trailing,isPresented: generalCheck) {
                    let condOne = (self.unit.pax ?? 0) == 0
                    let condTwo = self.unit.label.isEmpty
                    return condOne || condTwo
                }
         
                
                Spacer()

            }
    }

}
