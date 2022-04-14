//
//  CounterGroup.swift
//  PokemonCounter
//
//  Created by Mictel on 2022/4/2.
//

import SwiftUI
import Combine

struct CounterGroup: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var mode: PMDataModel.DefaultTemplateMode = .default7
    
    @State var bottomHeight: CGFloat = 130
    let maxShowFilterRulersCount = 10
    let rulersRowHeight:CGFloat = 55.0
    
    @StateObject var counterGroupController = PMCounterGroupController()
    @State private var keyboardShowed: Bool = false
    
    init(mode: PMDataModel.DefaultTemplateMode){
        self.mode = mode
        _title = State(initialValue: self.mode.rawValue)
    }
    
    @State private var title:String = ""
    @State private var showNewAlert = false
    @State private var showResetAlert = false
    
    var body: some View {
        let memo = Binding<String>(
            get: { self.counterGroupController.memo },
            set: { self.counterGroupController.memo = $0; self.memoChanged($0) }
        )
        
        VStack(spacing:0){
            ScrollView{
                VStack(spacing:20){
                    if counterGroupController.unFinishedCounters.collection.count > 0{
                        VStack(spacing:0){
                            HStack{
                                Text("未完成组合")
                                Spacer()
                                Text("\(counterGroupController.unFinishedCounters.collection.count) 组")
                                
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
                                Text("\(counterGroupController.finishedCounters.collection.count) 组")
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
                    
                    Button {
                        showResetAlert = true
                    } label: {
                        HStack{
                            Image(systemName: "arrow.clockwise.circle")
                                .foregroundColor(greenColor)
                            Text("重置本轮")
                                .foregroundColor(greenColor)
                                .font(Font.system(size: 20, weight: .medium))
                        }
                        .padding(EdgeInsets(top: 30, leading: 10, bottom: 5, trailing: 30))
                    }
                    .actionSheet(isPresented: $showResetAlert) {
                        ActionSheet(title: Text(""), message: Text("是否重置本轮 ?"), buttons: [
                            .default(Text("是")) {
                                if let counterGroup = counterGroupController.counterGroup{
                                    for counter in counterGroup.counters!.array{
                                        (counter as! PMCounter).finished = false
                                        (counter as! PMCounter).finishTime = Date()
                                        (counter as! PMCounter).shiny = false
                                    }
                                    counterGroup.memo = ""
                                    counterGroup.timestamp = Date()
                                    
                                    counterGroupController.load(counterGroup: counterGroup, dataContext: viewContext, showShinyCount: true)
                                    counterGroupController.counters = counterGroupController.counters
                                }
                                
                                do{
                                    try viewContext.save()
                                }catch{
                                    fatalError(error.localizedDescription)
                                }
                                
                                showResetAlert = false
                            },
                            .cancel(Text("否")) {
                                showResetAlert = false
                            }
                        ])
                    }
                    
                    Button {
                        showNewAlert = true
                    } label: {
                        HStack{
                            Image(systemName: "plus.circle")
                                .foregroundColor(greenColor)
                            Text("开始新的一轮")
                                .foregroundColor(greenColor)
                                .font(Font.system(size: 20, weight: .medium))
                        }
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 30, trailing: 30))
                    }
                    .actionSheet(isPresented: $showNewAlert) {
                        ActionSheet(title: Text(""), message: Text("是否开始新的一轮 ?"), buttons: [
                            .default(Text("是")) {
                                let dataModel = PMDataModel(dataContext: viewContext)
                                let counterGroup = PMCounterGroup(context: viewContext)
                                counterGroup.templateName = self.mode.rawValue
                                counterGroup.timestamp = Date()
                                counterGroup.counters = dataModel.getDefaultTemplateCounters(mode: self.mode)
                                counterGroupController.load(counterGroup: counterGroup, dataContext: viewContext, showShinyCount: true)
                                do{
                                    try viewContext.save()
                                }catch{
                                    fatalError(error.localizedDescription)
                                }
                                counterGroupController.counters = counterGroupController.counters
                                showNewAlert = false
                            },
                            .cancel(Text("否")) {
                                showNewAlert = false
                            }
                        ])
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 190, trailing: 10))
            }
            .animation(.easeInOut, value: counterGroupController.filterCounters.collection.count)
            .overlay(
                VStack{
                    if !keyboardShowed {
                        Spacer()
                        VStack(spacing:0){
                            ScrollView{
                                VStack(spacing:0){
                                    HStack{
                                        Text("\(counterGroupController.filterCounters.collection.count) 组匹配")
                                            .foregroundColor(barColor2.opacity(0.8))
                                            .font(Font.system(size: 15))
                                            .frame(height:rulersRowHeight)
                                            .opacity(counterGroupController.filterCounters.collection.count > 0 ? 1.0 : 0.0)
                                            .animation(.none, value: counterGroupController.filterCounters.collection.count)
                                        Spacer()
                                        Button {
                                            counterGroupController.counters = counterGroupController.counters
                                            counterGroupController.currentCounter.ruler.removeAll()
                                        } label: {
                                            Image(systemName:"xmark.circle.fill")
                                                .font(Font.system(size: 30))
                                                .foregroundColor(barColor2.opacity(0.8))
                                        }
                                    }
                                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                                    ForEach(counterGroupController.filterCounters.collection.indices, id:\.self){ inx in
                                        MyCounterRulerView(counter: counterGroupController.filterCounters.collection[inx], hideCount: self.counterGroupController.currentCounter.ruler.count)
                                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                                            .frame(height:rulersRowHeight)
                                            .background(inx % 2 == 1 ? Color(red:1.0, green:1.0, blue:1.0) : Color(red:0.97, green:0.97, blue:0.97))
                                            .animation(.none, value: counterGroupController.filterCounters.collection[inx].ruler)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            VStack{
                                HStack{
                                    if counterGroupController.currentCounter.ruler.count > 0{
                                        counterGroupController.currentCounter.body()
                                    }else{
                                        Text("按顺序输入 筛选未完成组合")
                                            .foregroundColor(Color.white)
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                }
                                .frame(minHeight:60)
                                HStack{
                                    Button {
                                        counterGroupController.counters = counterGroupController.counters
                                        counterGroupController.currentCounter.ruler.append(1)
                                    } label: {
                                        Text("1")
                                            .font(Font.system(size: 16, weight: Font.Weight.bold, design: Font.Design.rounded))
                                            .frame(width:36, height:36)
                                            .background(Color.white)
                                            .foregroundColor(barColor2)
                                            .cornerRadius(18)
                                    }
                                    Button {
                                        counterGroupController.counters = counterGroupController.counters
                                        counterGroupController.currentCounter.ruler.append(2)
                                    } label: {
                                        Text("2")
                                            .font(Font.system(size: 16, weight: Font.Weight.bold, design: Font.Design.rounded))
                                            .frame(width:36, height:36)
                                            .background(Color.white)
                                            .foregroundColor(barColor2)
                                            .cornerRadius(18)
                                    }
                                    Button {
                                        counterGroupController.counters = counterGroupController.counters
                                        counterGroupController.currentCounter.ruler.append(3)
                                    } label: {
                                        Text("3")
                                            .font(Font.system(size: 16, weight: Font.Weight.bold, design: Font.Design.rounded))
                                            .frame(width:36, height:36)
                                            .background(Color.white)
                                            .foregroundColor(barColor2)
                                            .cornerRadius(18)
                                    }
                                    Button {
                                        counterGroupController.counters = counterGroupController.counters
                                        counterGroupController.currentCounter.ruler.append(4)
                                    } label: {
                                        Text("4")
                                            .font(Font.system(size: 16, weight: Font.Weight.bold, design: Font.Design.rounded))
                                            .frame(width:36, height:36)
                                            .background(Color.white)
                                            .foregroundColor(barColor2)
                                            .cornerRadius(18)
                                    }
                                    Button {
                                        if counterGroupController.currentCounter.ruler.count > 0{
                                            counterGroupController.counters = counterGroupController.counters
                                            counterGroupController.currentCounter.ruler.removeLast()
                                        }
                                    } label: {
                                        Image(systemName: "delete.left.fill")
                                            .font(Font.system(size: 16, weight: Font.Weight.bold, design: Font.Design.rounded))
                                            .frame(width:36, height:36)
                                            .background(Color.white)
                                            .foregroundColor(barColor2)
                                            .cornerRadius(18)
                                    }
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: bottomHeight, maxHeight: bottomHeight)
                            .background(LinearGradient(colors: [barColor1,barColor2], startPoint: .top, endPoint: .bottom))                            
                        }
                        .frame(maxWidth: .infinity, maxHeight:counterGroupController.filterCounters.collection.count > 0 ? bottomHeight + CGFloat(min(counterGroupController.filterCounters.collection.count + 1,maxShowFilterRulersCount)) * rulersRowHeight : bottomHeight)
                        .cornerRadius(40)
                        .shadow(color: Color.black.opacity(0.2), radius: 20.0, x: 0.0, y: 15.0)
                        .animation(.easeInOut, value: counterGroupController.filterCounters.collection.count)
                    }
                }
                    .padding()
                    .background(counterGroupController.filterCounters.collection.count > 0 ? Color.black.opacity(0.85) : Color.clear)
                    .animation(.easeInOut, value: counterGroupController.filterCounters.collection.count)
            )
            .keyboardAdaptive()
            .onReceive(Publishers.keyboardShowed) { self.keyboardShowed = $0 }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear(){
            let dataModel = PMDataModel(dataContext: viewContext)
            if let counterGroup = dataModel.lastCounterGroup(mode: self.mode){
                counterGroupController.load(counterGroup: counterGroup, dataContext: viewContext, showShinyCount: true)
            }else{
                let counterGroup = PMCounterGroup(context: viewContext)
                counterGroup.templateName = self.mode.rawValue
                counterGroup.timestamp = Date()
                counterGroup.counters = dataModel.getDefaultTemplateCounters(mode: self.mode)
                counterGroupController.load(counterGroup: counterGroup, dataContext: viewContext, showShinyCount: true)
                do{
                    try viewContext.save()
                }catch{
                    fatalError(error.localizedDescription)
                }
            }
            counterGroupController.counters = counterGroupController.counters
        }
        .background(backgroundColor2)
        .navigationBarTitle(title)
        .navigationBarItems(trailing: HStack {
            NavigationLink(destination: {
                HistoryView(mode: self.mode, currentGroup: counterGroupController.counterGroup)
                    .environment(\.managedObjectContext, viewContext)
            }, label: {
                Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
                    .foregroundColor(Color.black.opacity(0.5))
            })
        })
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

struct CounterGroup_Previews: PreviewProvider {
    static var previews: some View {
        CounterGroup(mode: .default7)
    }
}

import AudioToolbox

struct MyCounterRulerView: View {
    @ObservedObject var counter: PMCounterController
    public var hideCount:Int = 0
    
    var body: some View {
        HStack{
            Button {
                if let rg = self.counter.counterGroup, let counterCounter = counter.counter{
                    AudioServicesPlaySystemSound(1519)

                    rg.counters = rg.counters
                    counter.finishTime = Date()
                    counter.finished.toggle()
                    counterCounter.finishTime = Date()
                    counterCounter.finished.toggle()
                    rg.save()
                }
            } label: {
                Image(systemName: counter.finished ? "checkmark.circle.fill": "circle.fill")
                    .font(Font.system(size: 25))
                    .foregroundColor(counter.finished ? greenColor.opacity(0.8) : Color.black.opacity(0.1))
            }
            Spacer()
            self.counter.body(hideCount: hideCount)
            Button {
                if let rg = self.counter.counterGroup, let counterCounter = counter.counter{
                    AudioServicesPlaySystemSound(1521)
                    
                    rg.counters = rg.counters
                    if !counter.shiny{
                        for r in rg.counters.collection{
                            r.shiny = false
                        }
                        if let counters = counterCounter.group?.counters?.array as? [PMCounter]{
                            for r in counters{
                                r.shiny = false
                            }
                        }
                    }
                    counterCounter.shiny.toggle()
                    counter.shiny.toggle()
                    rg.save()
                }
            } label: {
                Image(systemName: "sparkles")
                    .opacity(counter.shiny ? 1.0 : 0.2)
                    .foregroundColor(Color.orange)
                    .font(Font.system(size: 15))
            }
            if counter.shinyCount > 0 {
                HStack(spacing:0){
                Text("\(counter.shinyCount)")
                        .font(Font.system(size: 8, weight: Font.Weight.bold, design: Font.Design.rounded))
                    .foregroundColor(Color.white)
                }
                .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                .frame(height: 16)
                .background(Color.orange)
                .cornerRadius(8)
                .offset(x: 0, y: -9)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy 年 M 月 d 日 HH:mm:ss"
    return formatter
}()

public let redColor: Color = {
    return Color(red:220.0/255.0, green:90.0/255.0, blue:90.0/255.0)
}()

public let redColor2: Color = {
    return Color(red:220.0/255.0, green:90.0/255.0, blue:90.0/255.0)
}()

public let greenColor: Color = {
    return Color(red: 95.0/255.0, green: 190.0/255.0, blue: 190.0/255.0)
}()

public let orangeColor: Color = {
    return Color(red:210.0/255.0, green:210.0/255.0, blue:40.0/255.0)
}()

public let orangeColor2: Color = {
    return Color(red:190.0/255.0, green:190.0/255.0, blue:20.0/255.0)
}()

public let yellowColor: Color = {
    return Color(red:250.0/255.0, green:250.0/255.0, blue:65.0/255.0)
}()

public let barColor1: Color = {
    return Color(red:0.6, green:0.6, blue:0.6)
}()

public let barColor2: Color = {
    return Color(red:0.4, green:0.4, blue:0.4)
}()

public let barColor3: Color = {
    return Color(red:0.2, green:0.2, blue:0.2)
}()
