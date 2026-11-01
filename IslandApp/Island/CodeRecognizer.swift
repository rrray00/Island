import Foundation
import UIKit
import Vision

/// 截图识别结果
struct RecognizedCode {
    let code: String
    let confidence: Float
}

/// 用 Vision 框架离线识别截图中的取餐码 / 取件码（不联网，全部在本地）
final class CodeRecognizer {
    static let shared = CodeRecognizer()
    private init() {}

    /// 从图片中识别最可能的号码串
    func recognizeCode(from image: UIImage) async -> RecognizedCode? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: nil)
                    return
                }

                // 收集所有含数字的文本，按置信度排序
                var candidates: [(String, Float)] = []
                for obs in observations {
                    guard let top = obs.topCandidates(1).first else { continue }
                    let text = top.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    if text.contains(where: { $0.isNumber }) {
                        candidates.append((text, top.confidence))
                    }
                }

                candidates.sort { $0.1 > $1.1 }

                // 优先挑短串（取餐码通常不长，避免把长句当号码）
                let short = candidates
                    .filter { $0.0.count <= 12 }
                    .first ?? candidates.first

                if let best = short {
                    continuation.resume(returning: RecognizedCode(code: best.0, confidence: best.1))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["zh-Hans", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
}
