local GITHUB_RAW_URL = "https://raw.githubusercontent.com/aetheldeveloper/viethoascript/refs/heads/main/venyxhub.lua"
local AUTO_UPDATE_INTERVAL = 3600

if not getgenv().__VenyxV5Loaded then
    getgenv().__VenyxV5Loaded = true
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/ff2f66df8811e8d694770d532d0a0d1f.lua"))()
        end)
    end)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local CoreGui = game:GetService("CoreGui")

local roots = {
    gethui and gethui(),
    CoreGui,
    LocalPlayer:WaitForChild("PlayerGui")
}

local FastCache = {}

local EXACT_MATCH_VI = {
    ["Idle"] = "Đang rảnh", ["Waiting"] = "Đang chờ", ["Nothing"] = "Không có gì",
    ["Waiting in safe zone"] = "Đợi ở vùng an toàn", ["Returning to safe zone"] = "Đang về vùng an toàn",
    ["Returning home"] = "Đang quay về nhà", ["Going home"] = "Đang về nhà",
    ["Delivering egg"] = "Đang mang trứng về chuồng", ["Dropping egg"] = "Đang thả trứng",
    ["Dropping eggs"] = "Đang thả trứng", ["Selling eggs"] = "Đang bán trứng",
    ["Selling pets"] = "Đang bán pet", ["Selling lab eggs"] = "Đang bán trứng Lab",
    ["Hatching eggs"] = "Đang ấp trứng", ["Placing eggs"] = "Đang đặt trứng",
    ["Mutating eggs"] = "Đang đột biến trứng", ["Fusing pets"] = "Đang dung hợp pet",
    ["Hopping server"] = "Đang đổi máy chủ", ["Rejoining"] = "Đang vào lại phòng",
    ["Avoiding guard"] = "Đang né vệ sĩ", ["Evading guard"] = "Đang né vệ sĩ",
    ["Using treadmill"] = "Đang chạy máy tập", ["Upgrading treadmill"] = "Đang nâng cấp máy tập",
    ["Upgrading base"] = "Đang nâng cấp căn cứ", ["Claiming rewards"] = "Đang nhận thưởng",
    ["Claiming offline cash"] = "Đang nhận tiền ngoại tuyến", ["Catching shooting star"] = "Đang bắt sao băng",
    ["Catching butterfly"] = "Đang bắt bướm", ["Joining race"] = "Đang vào đường đua", ["Racing"] = "Đang đua xe",

    ["Dashboard"] = "Bảng Điều Khiển", ["Welcome back"] = "Chào mừng trở lại", ["Beta version"] = "Phiên bản Beta",
    ["This is a test build. Features may change and bugs can happen."] = "Đây là bản thử nghiệm. Tính năng có thể thay đổi và phát sinh lỗi.",
    ["Rejoin"] = "Vào lại", ["Server hop"] = "Đổi server", ["Copy Job ID"] = "Chép Job ID",
    ["Unload hub"] = "Tắt Hub", ["Save config"] = "Lưu cấu hình", ["Hide UI"] = "Ẩn Menu",
    ["SESSION"] = "PHIÊN CHƠI", ["STOLEN"] = "ĐÃ CƯỚP", ["LAST EGG"] = "TRỨNG CUỐI",
    ["PLACED"] = "ĐÃ ĐẶT", ["HATCHED"] = "ĐÃ ẤP", ["NIGHT IN"] = "ĐÊM SAU",
    ["SESSION TIME"] = "THỜI GIAN", ["BEST STEAL"] = "CƯỚP TỐT NHẤT", ["EGG BAG"] = "TÚI TRỨNG",
    ["PET BAG"] = "TÚI PET", ["WHAT'S NEW"] = "CÓ GÌ MỚI", ["NEW"] = "MỚI", ["Event"] = "Sự Kiện",
    ["Racing Event: ragdoll jump to the portal, races, leaves and claims"] = "Sự Kiện Đua Xe: tự nhảy vào cổng, đua, rời đi và nhận thưởng",
    ["Shooting Star catcher with ragdoll jump and run fallback"] = "Bắt Sao Băng kết hợp nhảy ragdoll và chạy dự phòng",
    ["Steal panel joins the game buttons and lists every egg"] = "Bảng Cướp tích hợp nút game và liệt kê mọi quả trứng",
    ["Search"] = "Tìm kiếm", ["Filter"] = "Lọc tìm",

    ["Steal"] = "Cướp Trứng", ["Auto Steal"] = "Tự Động Cướp", ["AUTO STEAL"] = "TỰ ĐỘNG CƯỚP",
    ["Auto steal"] = "Tự động cướp", ["Egg Predictor"] = "Dự Đoán Trứng", ["EGG PREDICTOR"] = "DỰ ĐOÁN TRỨNG",
    ["Go to egg"] = "Di chuyển tới trứng", ["Teleport to egg"] = "Dịch chuyển tới trứng", ["Tween"] = "Bay (Tween)",
    ["Delivery method"] = "Cách mang về", ["Fast tween speed"] = "Tốc độ bay nhanh", ["Tween speed"] = "Tốc độ bay",
    ["Steal missing index eggs"] = "Cướp trứng thiếu trong Chỉ mục", ["Steal back from players"] = "Cướp lại từ người chơi",
    ["Anti guard"] = "Chống vệ sĩ", ["Drop eggs at safe zone"] = "Thả trứng ở vùng an toàn",
    ["FILTER"] = "BỘ LỌC", ["Zones"] = "Khu vực", ["None"] = "Không có", ["Steal first"] = "Ưu tiên cướp",
    ["Best value"] = "Giá trị cao nhất", ["Lowest value"] = "Giá trị thấp nhất", ["Best rarity"] = "Độ hiếm cao nhất",
    ["Best mutation"] = "Đột biến tốt nhất", ["Biggest"] = "Kích thước to nhất", ["Closest"] = "Khoảng cách gần nhất",
    ["Mutations"] = "Đột biến", ["Rarities"] = "Độ hiếm", ["Only these eggs"] = "Chỉ những trứng này",
    ["Min value /s"] = "Giá trị tối thiểu /s", ["Off"] = "Tắt",
    ["Sell cheapest egg when bag is full"] = "Bán trứng rẻ nhất khi đầy túi", ["Keep lab eggs"] = "Giữ lại trứng Lab",
    ["AUTO HOP SERVER"] = "TỰ ĐỔI MÁY CHỦ", ["Only sell eggs below /s"] = "Chỉ bán trứng dưới mức /s",
    ["EGG SHOWCASE"] = "TRƯNG BÀY TRỨNG", ["Sort eggs"] = "Sắp xếp trứng", ["Preview card"] = "Thẻ xem trước",
    ["Pick one"] = "Chọn một mục", ["Pick any"] = "Chọn bất kỳ", ["Value"] = "Giá trị", ["Rarity"] = "Độ hiếm",
    ["Time left"] = "Thời gian còn lại", ["Default"] = "Mặc định", ["Clear"] = "Xóa chọn",
    ["Select all"] = "Chọn tất cả", ["SIZE"] = "KÍCH CỠ", ["WEIGHT"] = "CÂN NẶNG", ["READY"] = "SẴN SÀNG",
    ["IN BAG"] = "TRONG TÚI", ["GROWING"] = "ĐANG LỚN", ["Hatch now"] = "Ấp ngay",
    ["Hold egg"] = "Cầm trứng", ["Fly to egg"] = "Bay tới trứng",

    ["Enchanted Forest"] = "Rừng Phù Phép (Enchanted Forest)", ["Light Dark"] = "Sáng Tối (Light Dark)",
    ["Titan Temple"] = "Đền Titan (Titan Temple)", ["Cherry Blossom"] = "Hoa Anh Đào (Cherry Blossom)",
    ["Prehistoric"] = "Tiền Sử (Prehistoric)", ["Abyss Ocean"] = "Đáy Đại Dương (Abyss Ocean)",
    ["Volcano"] = "Núi Lửa (Volcano)", ["Snow"] = "Tuyết (Snow)", ["Jungle"] = "Rừng Rậm (Jungle)",
    ["Desert"] = "Sa Mạc (Desert)", ["Lake"] = "Hồ Nước (Lake)", ["Forest"] = "Khu Rừng (Forest)",
    ["Silver"] = "Bạc (Silver)", ["Rainbow"] = "Cầu Vồng (Rainbow)", ["Golden"] = "Vàng (Golden)",
    ["Fractured"] = "Rạn Nứt (Fractured)", ["Scrambled"] = "Hỗn Loạn (Scrambled)",
    ["Enchanted"] = "Phù Phép (Enchanted)", ["Nitro"] = "Nitro", ["SCRAMBLED"] = "HỖN LOẠN",
    ["NITRO"] = "NITRO", ["FRACTURED"] = "RẠN NỨT", ["ENCHANTED"] = "PHÙ PHÉP",

    ["Farm"] = "Cày Cuốc", ["Pen"] = "Chuồng Ấp", ["PEN"] = "CHUỒNG ẤP", ["Treadmill"] = "Máy Tập",
    ["TREADMILL"] = "MÁY TẬP CHẠY", ["Mutate"] = "Đột Biến", ["MUTATE"] = "ĐỘT BIẾN",
    ["Sell"] = "Bán", ["SELL"] = "BÁN TỰ ĐỘNG", ["Fuse"] = "Dung Hợp", ["FUSE"] = "DUNG HỢP",
    ["Priority"] = "Ưu Tiên", ["PRIORITY"] = "THỨ TỰ ƯU TIÊN", ["AUTO PLACE"] = "TỰ ĐỘNG ĐẶT TRỨNG",
    ["Auto place"] = "Tự động đặt trứng", ["Place when"] = "Đặt khi", ["Always"] = "Luôn luôn",
    ["Place first"] = "Ưu tiên đặt", ["AUTO HATCH"] = "TỰ ĐỘNG ẤP TRỨNG", ["Auto hatch"] = "Tự động ấp trứng",
    ["Equip best pets"] = "Trang bị pet mạnh nhất", ["READY NOW"] = "SẴN SÀNG ẤP",
    ["Auto treadmill"] = "Tự chạy máy tập", ["Auto upgrade treadmill"] = "Tự nâng cấp máy tập",
    ["PROGRESS"] = "TIẾN TRÌNH", ["Auto upgrade base"] = "Tự nâng cấp căn cứ",
    ["Auto buy trails"] = "Tự mua vệt sáng", ["Auto claim offline cash"] = "Tự nhận tiền ngoại tuyến",
    ["Auto claim index rewards"] = "Tự nhận thưởng Chỉ mục", ["AUTO MUTATE"] = "TỰ ĐỘNG ĐỘT BIẾN",
    ["Auto mutate"] = "Tự động đột biến", ["MUTATE FILTER"] = "BỘ LỌC ĐỘT BIẾN", ["Use items"] = "Dùng vật phẩm",
    ["Mutate first"] = "Ưu tiên đột biến", ["Auto buy Nitro"] = "Tự mua Nitro", ["PETS"] = "THÚ CƯNG (PETS)",
    ["EGGS"] = "TRỨNG (EGGS)", ["Auto sell pets"] = "Tự động bán pet", ["Auto sell eggs"] = "Tự động bán trứng",
    ["Sell rarities"] = "Độ hiếm bán", ["Never sell"] = "Không bao giờ bán", ["Only mutations"] = "Chỉ bán đột biến",
    ["Only below /s"] = "Chỉ dưới mức /s", ["Keep mutated"] = "Giữ lại đồ đột biến",
    ["Sell matching pets now"] = "Bán các pet khớp ngay", ["Sell matching eggs now"] = "Bán các trứng khớp ngay",
    ["LAB EGGS"] = "TRỨNG PHÒNG LAB", ["FAVORITE"] = "YÊU THÍCH (KHÓA)", ["Auto favorite"] = "Tự động khóa bảo vệ",
    ["Auto sell lab eggs"] = "Tự động bán trứng Lab", ["Sell matching lab eggs now"] = "Bán trứng Lab khớp ngay",
    ["Match"] = "Điều kiện khớp", ["All picked rules"] = "Khớp tất cả quy tắc", ["Any picked rule"] = "Khớp bất kỳ quy tắc",
    ["Always favorite"] = "Luôn khóa loài này", ["Favorite equipped"] = "Khóa pet đang trang bị",
    ["FUSE MACHINE"] = "MÁY DUNG HỢP", ["No 3 matching pets"] = "Chưa đủ 3 pet cùng loại",
    ["Auto fuse"] = "Tự động dung hợp", ["Fuse first"] = "Ưu tiên dung hợp", ["Lowest rarity"] = "Độ hiếm thấp nhất",
    ["Highest rarity"] = "Độ hiếm cao nhất", ["Use pets"] = "Sử dụng pet",
    ["Lowest value first"] = "Giá trị thấp nhất trước", ["Highest value first"] = "Giá trị cao nhất trước",
    ["Skip mutated"] = "Bỏ qua pet đột biến", ["Eject odd pets"] = "Đẩy pet lẻ ra ngoài",
    ["FUSE FILTER"] = "BỘ LỌC DUNG HỢP", ["Only these pets"] = "Chỉ những pet này",
    ["Never fuse"] = "Không bao giờ dung hợp", ["FUSE PREDICTOR"] = "DỰ ĐOÁN DUNG HỢP",
    ["SLOTS"] = "Ô CHỨA", ["STATUS"] = "TRẠNG THÁI", ["Waiting for pets"] = "Đang chờ pet",
    ["LIKELY SIZE"] = "KÍCH CỠ DỰ KIẾN", ["CHANCE"] = "TỶ LỆ", ["VALUE"] = "GIÁ TRỊ",
    ["BEST CASE"] = "TỐT NHẤT CÓ THỂ", ["TASK ORDER"] = "THỨ TỰ TÁC VỤ",
    ["Top goes first. A carried egg is always delivered first, and before the field opens every task waits in the safe zone."] = "Mục ở trên làm trước. Trứng đang bê luôn được về trước, và trước khi khu vực mở thì mọi tác vụ sẽ đợi ở vùng an toàn.",
    ["DOING"] = "ĐANG LÀM", ["WAITING"] = "ĐANG CHỜ", ["Steal filter eggs"] = "Cướp trứng theo bộ lọc",
    ["Shooting Star"] = "Bắt Sao Băng", ["Racing Event"] = "Sự Kiện Đua Xe", ["Butterfly"] = "Bắt Bướm",
    ["Steal wisp eggs"] = "Cướp trứng Wisp", ["Wisp"] = "Nhặt Wisp",
    ["Steal missing index"] = "Cướp trứng thiếu trong Chỉ mục", ["Steal lab eggs"] = "Cướp trứng phòng Lab",
    ["Place"] = "Đặt trứng vào chuồng", ["Butterfly machine"] = "Máy đổi Bướm",

    ["Race"] = "Đua Xe", ["RACE"] = "ĐUA XE", ["Star"] = "Sao Băng", ["STAR"] = "SAO BĂNG",
    ["BUTTERFLY"] = "BẮT BƯỚM", ["Lab"] = "Phòng Lab", ["LAB"] = "PHÒNG LAB", ["AA"] = "Admin (AA)",
    ["RACING EVENT"] = "SỰ KIỆN ĐUA XE", ["NEXT RACE"] = "ĐUA TIẾP THEO", ["WINS"] = "THẮNG",
    ["TROPHIES"] = "CÚP", ["Auto race"] = "Tự động đua xe", ["Race speed"] = "Tốc độ đua",
    ["Lower it if wins do not count"] = "Giảm tốc độ nếu thắng không được tính",
    ["Use power-ups"] = "Tự dùng vật phẩm tăng tốc", ["REWARDS"] = "PHẦN THƯỞNG",
    ["Auto claim rewards"] = "Tự nhận phần thưởng", ["Auto equip racer"] = "Tự trang bị xe đua",
    ["Racer"] = "Xe đua", ["Best owned"] = "Tốt nhất đang có", ["Auto buy shop"] = "Tự mua vật phẩm Shop",
    ["Shop items"] = "Vật phẩm Shop", ["SHOOTING STAR"] = "SAO BĂNG RƠI", ["LANDS IN"] = "RƠI SAU",
    ["CATCH"] = "BẮT SAO BĂNG",
    ["A Shooting Star is rare and only you can catch yours. It lands in Cosmic, runs from you, and needs a 1.6 s hold."] = "Sao Băng rất hiếm và chỉ bạn mới bắt được của mình. Nó rơi ở khu Vũ Trụ (Cosmic), chạy trốn bạn và cần nhấn giữ 1.6 giây.",
    ["CAUGHT"] = "ĐÃ BẮT", ["EXPIRES IN"] = "BIẾN MẤT SAU", ["SLIPPED"] = "TUỘT MẤT",
    ["TRIES"] = "SỐ LẦN THỬ", ["DISTANCE"] = "KHOẢNG CÁCH", ["Auto catch shooting star"] = "Tự động bắt sao băng",
    ["BUTTERFLY BLOOM"] = "MÙA BƯỚM NỞ", ["Auto butterfly bloom"] = "Tự động bắt bướm",
    ["EMERALD"] = "LỤC BẢO", ["SAPPHIRE"] = "LAM NGỌC", ["AMETHYST"] = "THẠCH ANH TÍM",
    ["RADIANT"] = "RỰC RỠ", ["ESSENCE"] = "TINH CHẤT", ["Catch mode"] = "Chế độ bắt",
    ["Stand"] = "Đứng yên", ["Chase"] = "Đuổi theo", ["BUTTERFLY MACHINE"] = "MÁY ĐỔI BƯỚM",
    ["Auto trade up"] = "Tự nâng cấp bậc bướm", ["Trade"] = "Giao dịch đổi",
    ["Smart trade for essence"] = "Đổi bướm lấy tinh chất thông minh", ["Auto craft essence"] = "Tự chế tạo tinh chất",
    ["WISP COMPANION"] = "ĐỒNG HÀNH WISP", ["Catch priority"] = "Ưu tiên bắt", ["Rarest"] = "Hiếm nhất",
    ["Catch"] = "Loại bướm bắt", ["Radiant"] = "Rực Rỡ (Radiant)", ["Catch speed"] = "Tốc độ bắt",
    ["Auto wisp quest"] = "Tự làm nhiệm vụ Wisp", ["Auto banjo cricket"] = "Tự bắt dế Banjo",
    ["STAGE"] = "GIAI ĐOẠN", ["LAB ODDS"] = "TỶ LỆ PHÒNG LAB", ["BANNER"] = "BĂNG RÔN",
    ["ENDS IN"] = "KẾT THÚC SAU", ["BANNER CHANCE"] = "TỶ LỆ BĂNG RÔN", ["NEXT"] = "TIẾP THEO",
    ["Experimental Pets"] = "Pet Thí Nghiệm", ["Biohazard Pets"] = "Pet Sinh Học",
    ["Lab banners"] = "Băng rôn phòng Lab", ["Auto trade in"] = "Tự động đổi trứng Lab",
    ["Auto reroll recipe"] = "Tự đổi lại công thức", ["Place lab reward eggs"] = "Đặt trứng thưởng từ Lab",
    ["ADMIN ABUSE"] = "LẠM DỤNG ADMIN (ABUSE)", ["No admin boost right now"] = "Hiện không có buff Admin nào",
    ["Instant steal (Admin Treadmill)"] = "Cướp tức thì (Máy tập Admin)",
    ["Use admin treadmill"] = "Tự dùng máy tập Admin", ["CAPTURE THE EGG"] = "CƯỚP TRỨNG SỰ KIỆN",
    ["Auto capture event egg"] = "Tự bắt trứng sự kiện", ["Take it from the holder"] = "Giật trứng từ người đang cầm",
    ["Hold height"] = "Độ cao giữ trứng", ["Keep away"] = "Khoảng cách né tránh",
    ["MINIGAME EGGS"] = "TRỨNG MINIGAME",
    ["Waiting for Red Light Green Light or T-Rex Run"] = "Đang chờ Đèn Đỏ Đèn Xanh hoặc Chạy Trốn T-Rex",
    ["Auto steal minigame egg"] = "Tự cướp trứng Minigame",

    ["Player"] = "Người Chơi", ["ESP"] = "Định Vị (ESP)", ["Move"] = "Di Chuyển", ["MOVE"] = "DI CHUYỂN",
    ["Combat"] = "Chiến Đấu", ["COMBAT"] = "CHIẾN ĐẤU", ["FIELD EGGS"] = "TRỨNG NGOÀI SÂN",
    ["Egg ESP"] = "ESP Trứng", ["Show"] = "Hiển thị", ["Name"] = "Tên", ["Fixed size"] = "Cố định kích cỡ",
    ["OTHERS"] = "MỤC KHÁC", ["Pen egg ESP"] = "ESP trứng trong chuồng", ["Other pens ESP"] = "ESP chuồng người khác",
    ["Guard ESP"] = "ESP Vệ sĩ", ["Player ESP"] = "ESP Người chơi", ["ESP size"] = "Kích cỡ ESP",
    ["MOVEMENT"] = "TỐC ĐỘ & DI CHUYỂN", ["Speed boost"] = "Tăng tốc chạy", ["Boost speed"] = "Tốc độ tăng thêm",
    ["Infinite jump"] = "Nhảy vô hạn", ["God mode"] = "Bất tử (God mode)", ["PROTECTION"] = "BẢO VỆ NHÂN VẬT",
    ["Anti ragdoll"] = "Chống ngã (Anti Ragdoll)", ["Ignore traps"] = "Bỏ qua bẫy",
    ["Instant prompts"] = "Tương tác nhấn giữ tức thì", ["Anti AFK"] = "Chống treo máy (Anti AFK)",
    ["Invisible"] = "Tàng hình", ["AUTO HIT"] = "TỰ ĐỘNG ĐÁNH", ["Auto hit"] = "Tự động đánh",
    ["Hit who"] = "Mục tiêu đánh", ["Nearest player"] = "Người chơi gần nhất",
    ["Chosen player"] = "Người chơi chỉ định", ["Chase speed"] = "Tốc độ đuổi theo",
    ["HIT AURA"] = "VÒNG ĐÁNH TỰ ĐỘNG", ["Hit aura"] = "Vòng đánh tự động (Hit Aura)",
    ["Skip friends"] = "Bỏ qua bạn bè", ["WEAPONS"] = "VŨ KHÍ", ["Use weapons"] = "Sử dụng vũ khí",
    ["Hold each"] = "Thời gian cầm mỗi món", ["System"] = "Hệ Thống", ["Server"] = "Máy Chủ",
    ["SERVER"] = "MÁY CHỦ", ["Webhook"] = "Webhook", ["WEBHOOK"] = "WEBHOOK",
    ["Optimizer"] = "Tối Ưu Hóa", ["OPTIMIZER"] = "TỐI ƯU HÓA (GIẢM LAG)", ["Interface"] = "Giao Diện",
    ["Config"] = "Cấu Hình", ["Hop to"] = "Chuyển tới server", ["Least players"] = "Ít người chơi nhất",
    ["Hop server"] = "Đổi máy chủ", ["Hop"] = "Đổi ngay", ["Rejoin this server"] = "Vào lại máy chủ này",
    ["Copy"] = "Sao chép", ["JOIN AND STAY"] = "VÀO PHÒNG & DUY TRÌ", ["Job ID"] = "Mã phòng (Job ID)",
    ["Paste a Job ID"] = "Dán mã Job ID vào đây", ["Join that server"] = "Vào máy chủ đó",
    ["Join"] = "Vào ngay", ["Rejoin on kick"] = "Tự vào lại khi bị văng/kick",
    ["Auto load script"] = "Tự chạy lại script khi chuyển server", ["DISCORD WEBHOOK"] = "WEBHOOK DISCORD",
    ["Webhook URL"] = "Đường dẫn Webhook", ["Ping everyone"] = "Tag @everyone",
    ["WHAT TO POST"] = "NỘI DUNG GỬI BÁO CÁO", ["Post stolen eggs"] = "Báo cáo trứng cướp được",
    ["Post fused eggs"] = "Báo cáo trứng dung hợp", ["POSTED"] = "ĐÃ GỬI",
    ["Send a test post"] = "Gửi tin nhắn thử nghiệm", ["Test"] = "Thử nghiệm",
    ["Post when bag is full"] = "Gửi thông báo khi đầy túi", ["GRAPHICS"] = "ĐỒ HỌA",
    ["Low graphics"] = "Đồ họa thấp (Tăng FPS)", ["Disable 3D Render"] = "Tắt kết xuất 3D (Treo máy)",
    ["Background color"] = "Màu nền màn hình", ["Black"] = "Màu Đen", ["White"] = "Màu Trắng",
    ["Hide game UI"] = "Ẩn giao diện gốc của Game", ["FRAME RATE"] = "TỐC ĐỘ KHUNG HÌNH (FPS)",
    ["FPS cap"] = "Giới hạn FPS", ["Show FPS and ping"] = "Hiện chỉ số FPS và Ping",
    ["BASES"] = "CĂN CỨ (BASES)", ["Hide other players' pets and eggs"] = "Ẩn pet và trứng của người chơi khác",
    ["Hide my pets and eggs"] = "Ẩn pet và trứng của bản thân",

    ["Common"] = "Phổ Thông (Common)", ["Uncommon"] = "Thường (Uncommon)", ["Rare"] = "Hiếm (Rare)",
    ["Epic"] = "Sử Thi (Epic)", ["Legendary"] = "Huyền Thoại (Legendary)", ["Mythic"] = "Thần Thoại (Mythic)",
    ["Cosmic"] = "Vũ Trụ (Cosmic)", ["Secret"] = "Bí Ẩn (Secret)", ["Divine"] = "Thánh Thần (Divine)",
    ["Eternal"] = "Vĩnh Cửu (Eternal)", ["COMMON"] = "PHỔ THÔNG", ["UNCOMMON"] = "THƯỜNG",
    ["RARE"] = "HIẾM", ["EPIC"] = "SỬ THI", ["LEGENDARY"] = "HUYỀN THOẠI", ["MYTHIC"] = "THẦN THOẠI",
    ["COSMIC"] = "VŨ TRỤ", ["SECRET"] = "BÍ ẨN", ["DIVINE"] = "THÁNH THẦN", ["ETERNAL"] = "VĨNH CỬU"
}

local PATTERNS_VI = {
    { pat = "^QUICK BAR (%d+)$", rep = "THANH NHANH %1" },
    { pat = "^ALL (%d+)$", rep = "TẤT CẢ %1" },
    { pat = "^READY (%d+)$", rep = "SẴN SÀNG %1" },
    { pat = "^GROWING (%d+)$", rep = "ĐANG LỚN %1" },
    { pat = "^IN BAG (%d+)$", rep = "TRONG TÚI %1" },
    { pat = "Pen (%d+/%d+) · (%d+) egg%(s%) ready to place", rep = "Chuồng %1 · %2 trứng sẵn sàng đặt" },
    { pat = "(%d+) egg%(s%) can be mutated", rep = "%1 trứng có thể đột biến" },
    { pat = "(%d+) pet%(s%) match", rep = "%1 pet khớp bộ lọc" },
    { pat = "(%d+) egg%(s%) match", rep = "%1 trứng khớp bộ lọc" },
    { pat = "(%d+) lab egg%(s%) match", rep = "%1 trứng Lab khớp bộ lọc" },
    { pat = "^(%d+) pets$", rep = "%1 thú cưng" },
    { pat = "(%d+ / %d+) players · (.+)", rep = "%1 người chơi · %2" },
    { pat = "Experimental Pets · needs (.-) · pity (%d+/%d+) · rerolls (%d+) · (.+)", rep = "Pet Thí Nghiệm · cần %1 · bảo hiểm %2 · lượt đổi %3 · %4" },
    { pat = "Biohazard Pets · needs (.-) · pity (%d+/%d+) · rerolls (%d+) · (.+)", rep = "Pet Sinh Học · cần %1 · bảo hiểm %2 · lượt đổi %3 · %4" },
    { pat = "Unstable DNA · needs (.-) · pity (%d+/%d+) · rerolls (%d+) · (.+)", rep = "DNA Bất Ổn · cần %1 · bảo hiểm %2 · lượt đổi %3 · %4" },
    { pat = "^Mythic · 1 in ([%d%.]+)$", rep = "Thần Thoại · 1 trên %1" },
    { pat = "^Cosmic · 1 in ([%d%.]+)$", rep = "Vũ Trụ · 1 trên %1" },
    { pat = "^Secret · 1 in ([%d%.]+)$", rep = "Bí Ẩn · 1 trên %1" },
    { pat = "^Divine · 1 in ([%d%.]+)$", rep = "Thánh Thần · 1 trên %1" },
    { pat = "^Eternal · 1 in ([%d%.]+)$", rep = "Vĩnh Cửu · 1 trên %1" },

    { pat = "^[Cc]arrying (.+) to safe zone$", rep = "Đang mang %1 về vùng an toàn" },
    { pat = "^[Cc]arrying (.+) to base$", rep = "Đang mang %1 về căn cứ" },
    { pat = "^[Cc]arrying (.+) to pen$", rep = "Đang mang %1 về chuồng" },
    { pat = "^[Cc]arrying (.+) home$", rep = "Đang mang %1 về nhà" },
    { pat = "^[Cc]arrying (.+)$", rep = "Đang bê %1" },
    { pat = "^[Dd]elivering (.+) to (.+)$", rep = "Đang giao %1 tới %2" },
    { pat = "^[Dd]elivering (.+) home$", rep = "Đang giao %1 về nhà" },
    { pat = "^[Dd]elivering (.+)$", rep = "Đang giao %1" },
    { pat = "^[Bb]ringing (.+) home$", rep = "Đang mang %1 về nhà" },
    { pat = "^[Bb]ringing (.+)$", rep = "Đang mang %1" },
    { pat = "^[Tt]aking (.+) from (.+)$", rep = "Đang giật %1 từ %2" },
    { pat = "^[Tt]aking (.+) home$", rep = "Đang đem %1 về nhà" },
    { pat = "^[Tt]aking (.+)$", rep = "Đang lấy %1" },
    { pat = "^[Ss]tealing (.+) from (.+)$", rep = "Đang cướp %1 từ %2" },
    { pat = "^[Ss]tealing (.+)$", rep = "Đang cướp %1" },
    { pat = "^[Gg]rabbing (.+)$", rep = "Đang chộp lấy %1" },
    { pat = "^[Pp]icking up (.+)$", rep = "Đang nhặt %1" },
    { pat = "^[Cc]ollecting (.+)$", rep = "Đang thu thập %1" },
    { pat = "^[Hh]olding (.+)$", rep = "Đang giữ %1" },
    { pat = "^[Cc]apturing (.+)$", rep = "Đang bắt giữ %1" },
    { pat = "^[Dd]ropping (.+) at (.+)$", rep = "Đang thả %1 tại %2" },
    { pat = "^[Dd]ropping (.+)$", rep = "Đang thả %1" },
    { pat = "^[Tt]weening to (.+)$", rep = "Đang bay tới %1" },
    { pat = "^[Tt]eleporting to (.+)$", rep = "Đang dịch chuyển tới %1" },
    { pat = "^[Gg]oing to (.+)$", rep = "Đang đi tới %1" },
    { pat = "^[Mm]oving to (.+)$", rep = "Đang di chuyển tới %1" },
    { pat = "^[Ww]alking to (.+)$", rep = "Đang chạy tới %1" },
    { pat = "^[Rr]unning to (.+)$", rep = "Đang chạy tới %1" },
    { pat = "^[Ff]lying to (.+)$", rep = "Đang bay tới %1" },
    { pat = "^[Rr]eturning to (.+)$", rep = "Đang quay về %1" },
    { pat = "^[Hh]eading to (.+)$", rep = "Đang hướng tới %1" },
    { pat = "^[Pp]lacing (.+)$", rep = "Đang đặt %1" },
    { pat = "^[Hh]atching (.+)$", rep = "Đang ấp %1" },
    { pat = "^[Mm]utating (.+)$", rep = "Đang đột biến %1" },
    { pat = "^[Ss]elling (.+)$", rep = "Đang bán %1" },
    { pat = "^[Ff]using (.+)$", rep = "Đang dung hợp %1" },
    { pat = "^[Uu]pgrading (.+)$", rep = "Đang nâng cấp %1" },
    { pat = "^[Bb]uying (.+)$", rep = "Đang mua %1" },
    { pat = "^[Cc]laiming (.+)$", rep = "Đang nhận %1" },
    { pat = "^[Ee]quipping (.+)$", rep = "Đang trang bị %1" },
    { pat = "^[Ff]avoriting (.+)$", rep = "Đang khóa bảo vệ %1" },
    { pat = "^[Ee]jecting (.+)$", rep = "Đang đẩy %1 ra" },
    { pat = "^[Cc]atching (.+)$", rep = "Đang bắt %1" },
    { pat = "^[Cc]hasing (.+)$", rep = "Đang đuổi theo %1" },
    { pat = "^[Aa]ttacking (.+)$", rep = "Đang tấn công %1" },
    { pat = "^[Hh]itting (.+)$", rep = "Đang đánh %1" },
    { pat = "^[Kk]illing (.+)$", rep = "Đang hạ %1" },
    { pat = "^[Tt]rading (.+) for (.+)$", rep = "Đang đổi %1 lấy %2" },
    { pat = "^[Tt]rading in (.+)$", rep = "Đang đổi %1" },
    { pat = "^[Tt]rading (.+)$", rep = "Đang giao dịch %1" },
    { pat = "^[Cc]rafting (.+)$", rep = "Đang chế tạo %1" },
    { pat = "^[Rr]erolling (.+)$", rep = "Đang đổi lại %1" },
    { pat = "^[Aa]voiding (.+)$", rep = "Đang né %1" },
    { pat = "^[Ee]vading (.+)$", rep = "Đang tránh %1" },
    { pat = "^[Ww]aiting for (.+)$", rep = "Đang chờ %1" },
    { pat = "^[Ww]aiting in (.+)$", rep = "Đang đợi ở %1" },
    { pat = "^[Ww]aiting %((.+)%)$", rep = "Đang chờ (%1)" },
    { pat = "^[Ss]earching for (.+)$", rep = "Đang tìm %1" },
    { pat = "^[Ll]ooking for (.+)$", rep = "Đang tìm %1" },
    { pat = "^[Ff]arming (.+)$", rep = "Đang cày %1" },
    { pat = "^[Uu]sing (.+)$", rep = "Đang dùng %1" },
    { pat = "^[Jj]oining (.+)$", rep = "Đang tham gia %1" },
    { pat = "^[Hh]opping (.+)$", rep = "Đang đổi %1" }
}

local function translateText(raw)
    if not raw or raw == "" then return raw end
    if FastCache[raw] then return FastCache[raw] end

    local normalized = (raw:match("^%s*(.-)%s*$") or raw):gsub("%s+", " ")

    if EXACT_MATCH_VI[normalized] then
        local out = EXACT_MATCH_VI[normalized]
        FastCache[raw] = out
        return out
    end

    local prefix, wordPart = normalized:match("^([^%w%s]+%s*)(.+)$")
    if prefix and wordPart then
        if EXACT_MATCH_VI[wordPart] then
            local out = prefix .. EXACT_MATCH_VI[wordPart]
            FastCache[raw] = out
            return out
        end
        for _, item in ipairs(PATTERNS_VI) do
            if wordPart:find(item.pat) then
                local out = prefix .. wordPart:gsub(item.pat, item.rep)
                FastCache[raw] = out
                return out
            end
        end
    end

    for _, item in ipairs(PATTERNS_VI) do
        if normalized:find(item.pat) then
            local out = normalized:gsub(item.pat, item.rep)
            FastCache[raw] = out
            return out
        end
    end

    FastCache[raw] = raw
    return raw
end

local function applyTranslation(inst)
    if inst:GetAttribute("__IsTranslating") then return end

    if inst:IsA("TextBox") then
        local origPh = inst:GetAttribute("__OrigPh")
        if not origPh and inst.PlaceholderText ~= "" then
            origPh = inst.PlaceholderText
            inst:SetAttribute("__OrigPh", origPh)
        end
        if origPh then
            local mapped = translateText(origPh)
            if inst.PlaceholderText ~= mapped then
                inst:SetAttribute("__IsTranslating", true)
                pcall(function() inst.PlaceholderText = mapped end)
                task.defer(inst.SetAttribute, inst, "__IsTranslating", false)
            end
        end
        return
    end

    local currentText = inst.Text
    if not currentText or currentText == "" then return end

    if currentText ~= inst:GetAttribute("__LastTranslated") then
        inst:SetAttribute("__OrigText", currentText)
    end

    local origText = inst:GetAttribute("__OrigText") or currentText
    local mapped = translateText(origText)

    if currentText ~= mapped then
        inst:SetAttribute("__IsTranslating", true)
        inst:SetAttribute("__LastTranslated", mapped)
        pcall(function() inst.Text = mapped end)
        task.defer(inst.SetAttribute, inst, "__IsTranslating", false)
    end
end

local function hookTextElement(inst)
    if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then return end

    applyTranslation(inst)

    if inst:GetAttribute("__TransHooked") then return end
    inst:SetAttribute("__TransHooked", true)

    local prop = inst:IsA("TextBox") and "PlaceholderText" or "Text"
    inst:GetPropertyChangedSignal(prop):Connect(function()
        if not inst:GetAttribute("__IsTranslating") and inst[prop] ~= inst:GetAttribute("__LastTranslated") then
            applyTranslation(inst)
        end
    end)
end

local function attachTranslatorToGui(gui)
    for _, desc in ipairs(gui:GetDescendants()) do
        hookTextElement(desc)
    end

    if not gui:GetAttribute("__TranslatorAttached") then
        gui:SetAttribute("__TranslatorAttached", true)
        gui.DescendantAdded:Connect(function(newDesc)
            task.defer(hookTextElement, newDesc)
        end)
    end
end

local function findAndHookVenyx()
    for _, root in ipairs(roots) do
        if root then
            for _, gui in ipairs(root:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "RobloxGui" and gui.Name ~= "TopBarApp" then
                    if gui:GetAttribute("__TranslatorAttached") then
                        attachTranslatorToGui(gui)
                        return true
                    end
                    for _, d in ipairs(gui:GetDescendants()) do
                        if (d:IsA("TextLabel") or d:IsA("TextButton")) and (d.Text == "VENYX" or d.Text == "Dashboard" or d.Text == "Bảng Điều Khiển") then
                            attachTranslatorToGui(gui)
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

task.spawn(function()
    for _ = 1, 30 do
        local ok, hooked = pcall(findAndHookVenyx)
        if ok and hooked then break end
        task.wait(0.4)
    end
end)

if GITHUB_RAW_URL ~= "" and not getgenv().__AutoUpdateTranslatorLoop then
    getgenv().__AutoUpdateTranslatorLoop = true
    local lastFetchedCode = ""
    task.spawn(function()
        while task.wait(AUTO_UPDATE_INTERVAL) do
            pcall(function()
                local freshCode = game:HttpGet(GITHUB_RAW_URL .. "?t=" .. tostring(os.time()))
                if freshCode and #freshCode > 100 and freshCode ~= lastFetchedCode then
                    if lastFetchedCode ~= "" then
                        loadstring(freshCode)()
                    end
                    lastFetchedCode = freshCode
                end
            end)
        end
    end)
end
