import SwiftUI

struct FishingShopView: View {
    @ObservedObject private var manager = FishingShopManager.shared

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // 左边标签栏
                VStack(spacing: 0){
                    ForEach(FishingShopManager.ShopTab.allCases, id: \.self) { tab in
                        Button(tab.rawValue) {
                            manager.selectedTab = tab
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(manager.selectedTab == tab ? 0.3 : 0.2))
                    }
                    Spacer()
                }
                .frame(maxWidth: 50)
                .background(Color.white)
                .padding(.trailing, 5)

                // 右边主内容区域
                VStack {
                    HStack {
                        Text("购物车: \(manager.totalCartPrice()) 金币")
                            .padding(7)
                            .background(Color.purple.opacity(0.5))
                            .cornerRadius(8)
                        Spacer()
                        CoinsView() // 你的金币组件
                            .padding(.trailing)
                    }

                    if manager.selectedTab == .cart {
                        CartTabView()
                    } else {
                        ShopTabView(tab: manager.selectedTab)
                    }
                }
            }
        }
        .padding(.top, 40)
    }
}

// 购物车视图
struct CartTabView: View {
    @ObservedObject private var manager = FishingShopManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(manager.cartItems.keys), id: \.id) { item in
                    HStack {
                        Text("\(item.name) x \(manager.cartItems[item] ?? 0)")
                        Spacer()
                        ForEach([-1, -10, -50, -100], id: \.self) { qty in
                            Button("\(qty)") {
                                manager.addToCart(item: item, quantity: qty)
                            }
                            .padding(6)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal)
                }
                HStack {
                    Button("购买全部") { manager.buyAll() }
                    Button("移除全部") { manager.removeAll() }
                }
                .padding(.top)
            }
            .padding()
        }
        .background(Color.white)
    }
}

// 商店分类页卡
struct ShopTabView: View {
    @ObservedObject private var manager = FishingShopManager.shared
    let tab: FishingShopManager.ShopTab
    @State private var selectedItem: StoreItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(manager.storeItems[tab] ?? []) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        HStack {
                            VStack {
                                Text(item.name)
                                    .font(.headline)
                                Text("\(item.price) 金币")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Image(item.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .background(Color.white)

        // 商品详情弹窗
        .sheet(item: $selectedItem) { item in
            VStack(spacing: 20) {
                Text(item.name).font(.largeTitle)
                Image(item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("价格：\(item.price) 金币")
                    .font(.headline)
                Text(item.description)
                    .padding()
                HStack {
                    ForEach([1, 10, 50, 100], id: \.self) { qty in
                        Button("+\(qty)") {
                            manager.addToCart(item: item, quantity: qty)
                        }
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(6)
                    }
                }
                Button("关闭") {
                    selectedItem = nil
                }
            }
            .padding()
        }
    }
}

#Preview {
    FishingShopView()
}
