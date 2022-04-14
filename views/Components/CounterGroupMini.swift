//
//  CounterGroup.swift
//  PokemonCounter
//
//  Created by Mictel on 2022/4/2.
//

import SwiftUI
import Combine

struct CounterGroupMini: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var mode: PMDataModel.DefaultTemplateMode = .default7
    
    let rulersRowHeight:CGFloat = 55.0
    
    @StateObject var counterGroupController = PMCounterGroupController()
    @State private var keyboardShowed: Bool = false
    
    private var group: PMCounterGroup? = nil
    
    init(mode: PMDataModel.DefaultTemplateMode, group: PMCounterGroup?){
        self.mode = mode
        self.group = group
        _title = State(initialValue: itemFormatter.string(from: self.group!.timestamp!))
    }
    
    @State private var title:String = ""
    
    var body: some View {
        let memo = Binding<String>(
            get: { self.counterGroupController.memo },
            set: { self.counterGroupController.memo = $0; self.memoChanged($0) }
        )
        
        VStack(spacing:0){
            ScrollView{
                VStack(spacing:10){
                    if counterGroupController.unFinishedCounters.collection.count > 0{
                        VStack(spacing:0){
                            HStack{
                                Text("未完成组合")
                                Spacer()
                                Text("× \(counterGroupController.unFinishedCounters.collection.count) 组")
                                
                            }
                            .foregroundColor(Color.white)
                            .padding()
                            
                            ForEach(counterGroupController.unFinishedCounters.collection.indices, id:\.self){ inx in
                                MyCounterRulerView(counter: counterGroupController.unFinishedCounters.collection[inx])
                                    .frame(height:rulersRowHeight)
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                    .background(inx % 2 == 0 ? Color(red:0.95, green:0.95, blue:0.95) : Color(red:0.92, green:0.92, blue:0.92))
                            }
                        }
                        .background(redColor)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 10.0, x: 0, y: 2)
                        .animation(.none, value: counterGroupController.unFinishedCounters.collection.count)
                    }
                    
                    if counterGroupController.finishedCounters.collection.count > 0{
                        VStack(spacing:0){
                            HStack{
                                Text("已完成组合")
                                Spacer()
                                Text("× \(counterGroupController.finishedCounters.collection.count) 组")
                            }
                            .foregroundColor(Color.white)
                            .padding()
                            
                            .foregroundColor(Color.gray)
                            ForEach(counterGroupController.finishedCounters.collection.indices, id:\.self){ inx in
                                MyCounterRulerView(counter: counterGroupController.finishedCounters.collection[inx])
                                    .frame(height:rulersRowHeight)
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                    .background(inx % 2 == 0 ? Color(red:0.95, green:0.95, blue:0.95) : Color(red:0.92, green:0.92, blue:0.92))
                            }
                        }
                        .background(greenColor)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 10.0, x: 0, y: 2)
                        .animation(.none, value: counterGroupController.finishedCounters.collection.count)
                    }
                    
                    VStack{
                        TextField("备注",text: memo)
                            .frame(maxWidth: .infinity)
                            .font(Font.system(size: 15))
                            .foregroundColor(Color.black.opacity(0.5))
                            .padding(20)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            
                        Text(counterGroupController.timestamp, formatter: itemFormatter)
                            .font(Font.system(size: 12))
                            .foregroundColor(Color.black.opacity(0.3))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    }

                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10))
            }
            .animation(.easeInOut, value: counterGroupController.filterCounters.collection.count)
            .keyboardAdaptive()
            .onReceive(Publishers.keyboardShowed) { self.keyboardShowed = $0 }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear(){
            if let counterGroup = self.group{
                counterGroupController.load(counterGroup: counterGroup, dataContext: viewContext, showShinyCount: false)
            }
            counterGroupController.counters = counterGroupController.counters
        }
        .background(backgroundColor2)
        .navigationBarTitle(title, displayMode: .inline)
    }
    
    func memoChanged(_ text: String){
        if let counterGroup = self.counterGroupController.counterGroup {
            if counterGroup.memo != text{
                counterGroup.memo = text
                self.counterGroupController.save()
            }
        }
    }
}

struct CounterGroupMini_Previews: PreviewProvider {
    static var previews: some View {
        CounterGroupMini(mode: .default7, group: nil)
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy 年 M 月 d 日 HH:mm:ss"
    return formatter
}()

