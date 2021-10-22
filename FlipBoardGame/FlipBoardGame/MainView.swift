import SwiftUI

struct MainView: View {
    @ObservedObject
    private var viewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach((0...14), id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach((0...14), id: \.self) { colIndex in
                        Button(action: {
                            viewModel.changeColor(rowIndex, colIndex)
                        }) {
                            Rectangle()
                                .fill(viewModel.gameFieldColors[rowIndex][colIndex])
                                .frame(width: 23, height: 23)
                                .border(.black, width: 1)
                        }
                    }
                }
            }
        }.padding()
        HStack {
            Text("Biggest Rectangle:")
            Text("\(viewModel.biggestRectangle.area)")
                .foregroundColor(.red)
        }
    }
    
    init() {
        self.viewModel = MainViewModel()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
