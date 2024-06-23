//
//  HOTimeImputationBuilderVM.swift
//  hoster
//
//  Created by Calogero Friscia on 01/06/24.
//

import Combine
import Foundation


/*
class HOTimeAmountBuilderVM:ObservableObject {
    
    private(set) var currentWriting:HOWritingAccount?
    private(set) var regolamento:Date?
    
    @Published var mese:Int?
    @Published var monthImputation:HOMonthImputation?
    
    @Published var anno:Int?
    
    @Published var ammortamento:Int?
    
    
    init(writing:HOWritingAccount?,regolamento:Date) {
        
        self.currentWriting = writing
        self.regolamento = regolamento
        
        compileBuilder()
    }
    
    private func compileBuilder() {
        
        guard let regolamento,
        let currentWriting,
        let area = currentWriting.operationArea,
        let type = currentWriting.type else { return }
        
        guard let timeImputation = area.getTimeImputation(throw: type) else { return }
        
        let components = Calendar.current.dateComponents([.month,.year], from: regolamento)
        
        self.mese = components.month
        self.anno = components.year
        
        
    }
}

extension HOTimeAmountBuilderVM {
    
     func updatePositiveValue(newValue:Int, to path:ReferenceWritableKeyPath<HOTimeAmountBuilderVM,Int?>) {
        
        guard newValue > 0 else {
           // self[keyPath: path] = nil
            self[keyPath: path] = nil
            return
        }
        
        self[keyPath: path] = newValue
        
    }
    
}*/ // deprecated
