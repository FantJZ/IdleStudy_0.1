//
//  PlayerBackpackDetailsView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/27.
//

import SwiftUI

// MARK: - 详情视图：鱼篓
struct FishBusketDetailView: View {
    let fish: FishInFishBusket
    @ObservedObject var manager: PlayerBackpackManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("鱼篓详情")
                .font(.title)
            
            // 显示图片
            if let uiImage = UIImage(named: fish.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else {
                Image(systemName: "fish")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
            }
            
            // 详细信息
            Text("名称：\(fish.name)")
            Text("品质：\(fish.quality)")
            Text("重量：\(String(format: "%.2f kg", fish.weight))")
            Text("价格：\(fish.price)")
            Text("稀有度：\(fish.rarity)")
            Text("经验：\(fish.exp)")
            
            Button("移到鱼库") {
                manager.moveFishToLibrary(fish)
            }
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}

// MARK: - 详情视图：鱼库
struct FishLibraryDetailView: View {
    let fish: FishInFishBusket
    
    var body: some View {
        VStack(spacing: 16) {
            Text("鱼库详情")
                .font(.title)
            
            if let uiImage = UIImage(named: fish.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else {
                Image(systemName: "fish")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
            }
            
            Text("名称：\(fish.name)")
            Text("品质：\(fish.quality)")
            Text("重量：\(String(format: "%.2f kg", fish.weight))")
            Text("价格：\(fish.price)")
            Text("稀有度：\(fish.rarity)")
            Text("经验：\(fish.exp)")
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}

// MARK: - 垃圾详情视图
struct GarbageDetailView: View {
    let item: BackpackGarbageItem
    
    var body: some View {
        VStack(spacing: 20) {
            Text("垃圾详情")
                .font(.title)
            
            // 这里同样可以放图片，但 BackpackGarbageItem 没有 image 字段
            // 如果想添加，可自行扩展
            Image(item.image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.black)
            
            Text("名称：\(item.name)")
                .font(.headline)
            Text("价格：\(item.price)")
            Text("池塘：\(item.pond)")
            Text("描述：\(item.description)")
            Text("总数：\(item.totalCount)")
            Text("钓到的总数：\(item.fishedCount)")
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}

// MARK: - 宝藏详情视图
struct TreasureDetailView: View {
    let item: BackpackTreasureItem
    
    var body: some View {
        VStack(spacing: 20) {
            Text("宝藏详情")
                .font(.title)
            
            // 同样可放置图片
            Image(systemName: "star")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.black)
            
            Text("名称：\(item.name)")
                .font(.headline)
            Text("价格：\(item.price)")
            Text("稀有度：\(item.rarity)")
            Text("池塘：\(item.pond)")
            Text("描述：\(item.description)")
            Text("总数：\(item.totalCount)")
            Text("钓到的总数：\(item.fishedCount)")
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}
