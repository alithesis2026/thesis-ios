import SwiftUI

struct SearchScreenView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        List(viewModel.results) { movie in
            Text(movie.title)
        }
        .searchable(text: $viewModel.queryText)
        .navigationTitle("Search")
    }
}
