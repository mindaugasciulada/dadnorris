extension String {
    func splitIntoChunks(preferredLength length: Int) -> [String] {
        var result: [String] = []
        var chars: [Character] = []
        
        for char in self {
            chars.append(char)
            if chars.count >= length, !char.isLetter {
                result.append(String(chars))
                chars.removeAll()
            }
        }
        
        if !chars.isEmpty {
            result.append(String(chars))
        }
        
        return result
    }
}
