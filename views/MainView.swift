//
//  ContentView.swift
//  Shared
//
//  Created by Mictel on 2022/4/2.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
        
    func getIconView(template: PMDataModel.DefaultTemplateMode) -> some View{
        HStack{
            if let mode = template{
                CounterGroup(mode: mode)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack {
                    ForEach(PMDataModel.DefaultTemplateMode.allValues, id:\.self) { template in
                        NavigationLink(destination: getIconView(template: template)) {
                            HStack{
                                Image("ball")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height:300)
                                    .overlay{
                                        Image(systemName: "sparkles")
                                            .foregroundColor(yellowColor)
                                            .font(Font.system(size: 70))
                                            .offset(x: -85, y: -85)
                                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                                        Text(template.rawValue)
                                            .font(Font.system(size: 20, weight: .medium))
                                            .frame(maxHeight:60)
                                            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                                            .background(LinearGradient(colors: [barColor2,barColor3], startPoint: .top, endPoint: .bottom))
                                            .cornerRadius(30)
                                            .offset(x: 70, y: 40)
                                            .foregroundColor(Color.white)
                                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MyButtonStyle())
                    }
                }
                .padding(EdgeInsets(top: 100, leading: 0, bottom: 20, trailing: 0))
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .background(
                GeometryReader { geometry in
                    HStack{
                        LinearGradient(colors: [backgroundColor,backgroundColor3], startPoint: .top, endPoint: .bottom)
                            .overlay{
                                let s = min(geometry.size.width, geometry.size.height)
                                Image(systemName: "sparkle")
                                    .font(Font.system(size: s > 0 ? s : 10))
                                    .foregroundColor(Color.white.opacity(0.05))
                                    .offset(x: -s / 3.0, y: -s / 2.0)
                                Image(systemName: "sparkle")
                                    .font(Font.system(size: s > 0 ? s : 10))
                                    .foregroundColor(Color.white.opacity(0.08))
                                    .offset(x: s / 3.0, y: s / 2.0)
                            }
                    }
                        .edgesIgnoringSafeArea(.all)
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(){
            let navBarAppearance = UINavigationBar.appearance()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(white: 0, alpha: 0.5)]
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(white: 0, alpha: 0.5)]
            navBarAppearance.tintColor = UIColor(white: 0, alpha: 0.5)
        }
    }
}

struct MyButtonStyle: ButtonStyle {
    public func makeBody(configuration: MyButtonStyle.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 1 : 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

public let backgroundColor: Color = {
    return Color(red: 95.0/255.0, green: 190.0/255.0, blue: 190.0/255.0)
}()

public let backgroundColor3: Color = {
    return Color(red: 55.0/255.0, green: 160.0/255.0, blue: 160.0/255.0)
}()

public let backgroundColor2: Color = {
    return Color(red: 0.9, green: 0.9, blue: 0.9)
}()

