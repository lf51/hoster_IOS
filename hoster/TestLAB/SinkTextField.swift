//
//  SinkTextField.swift
//  hoster
//
//  Created by Calogero Friscia on 11/03/24.
//

import Foundation
import Combine
import SwiftUI

/*public struct CSSinkStepper_1:View {
    
    @State private var value:Int
    
    let range:ClosedRange<Int>
    let step:Int
    
    let label:String?
    let labelText:Color?
    let labelBackground:Color?
    
    let numberFrameWidth:CGFloat
    
    let image:String?
    let imageColor:Color?
    
    let receiveAction:(_ :Int,_ :Int) -> Void
    
    public init(
        initialValue:Int? = nil,
        range:ClosedRange<Int>,
        step:Int = 1,
        label:String? = nil,
        labelText:Color? = nil,
        labelBackground:Color? = nil,
        image:String? = nil,
        imageColor:Color? = nil,
        numberWidth:CGFloat = 50,
        onChange:@escaping (_ oldValue:Int,_ newValue:Int) -> Void) {
        
            let startValue = initialValue != nil ? initialValue! : range.lowerBound
            
            self.value = startValue
            self.range = range
            self.step = step
            self.label = label
            self.labelText = labelText
            self.labelBackground = labelBackground
            self.numberFrameWidth = numberWidth
            self.image = image
            self.imageColor = imageColor
            self.receiveAction = onChange
    }
    
    public var body: some View {
        
        Stepper(
            value: $value,
            in: range,
            step: 1) {
                
                HStack(spacing:0) {
                    
                    if let label {
                        
                        Text(label)
                            .foregroundStyle(labelText ?? .black)
                            .bold()
                            .padding(6)
                            .background(labelBackground.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                    }
                    
                    HStack(spacing:0) {
                        
                        if let image {
                            
                            Image(systemName: image)
                                .imageScale(.large)
                                .foregroundStyle(imageColor ?? .white)
                                .padding(.leading)
                        }
                        
                        Text("\(value)")
                            .bold()
                            .fontDesign(.monospaced)
                            .frame(width: numberFrameWidth)
                            
                    }
                }
            }
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
            .onChange(of: value) { oldValue, newValue in
                receiveAction(oldValue,newValue)
            }
    }
    
}*/ // 12.03.24 migrato su MyTextFieldSinkPack

/*
public struct CSSinkTextField_4: View {
    
   // @Binding var textFieldItem: String
    @StateObject private var textVM: MyTextFieldViewModel
    
    let placeHolder: String
    let image: String
    let showDelete: Bool
    let keyboardType: UIKeyboardType
    
    let imageBasicColor:Color
    let imageActiveColor:Color
    let imageScale:Image.Scale
  //  let strokeColor:Color
    let textColor:Color
    
   public init(
    initialValue:String = "nil",
    placeHolder:String,
    image:String,
    imageBasicColor:Color = .black,
    imageActiveColor:Color = .green,
    imageScale:Image.Scale = .medium,
    /*strokeColor:Color = .blue,*/
    textColor:Color = .white,
    showDelete:Bool = false,
    keyboardType: UIKeyboardType = .default,
    onReceive:@escaping (_ newValue:String) -> Void) {
        
        let localVM = MyTextFieldViewModel(initialValue:initialValue,action:onReceive)
        _textVM = StateObject(wrappedValue: localVM)
        
        self.placeHolder = placeHolder
        self.image = image
        self.imageBasicColor = imageBasicColor
        self.imageActiveColor = imageActiveColor
        self.imageScale = imageScale
      //  self.strokeColor = strokeColor
        self.textColor = textColor
        self.showDelete = showDelete
        self.keyboardType = keyboardType
     
    }

   public var body: some View {
        
       let textIsNil = self.textVM.text == nil
       
       let text = Binding {
           self.textVM.text ?? ""
       } set: { newText in
           self.textVM.text = newText
       }
       
        HStack {
           
          Image(systemName: image)
                .imageScale(self.imageScale)
                .foregroundColor(!textIsNil ? self.imageActiveColor : self.imageBasicColor)
                .padding(.leading)
        
            TextField(self.placeHolder, text: text)
                .keyboardType(keyboardType)
                ._tightPadding()
                .accentColor(self.textColor)
            
            if showDelete {
                
                Button {
                  //  self.textVM.text = nil
                } label: {
                    Image(systemName: "x.circle")
                        .imageScale(.medium)
                        .foregroundColor(Color.white)
                        .opacity(textIsNil ? 0.3 : 1.0)
                        .padding(.trailing)
                }.disabled(textIsNil)
            }
            
        }
        .background {
            Color.gray.cornerRadius(5.0)
                .opacity(!textIsNil ? 0.6 : 0.2)
                .shadow(radius: 3.0)
        }
        .animation(Animation.easeInOut, value: self.textVM.text)
    }
}*/ // ok
