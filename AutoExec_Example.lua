-------------------------------------------------------------------------------
--! NTG UI AutoExec Example
--! วางไฟล์นี้ใน autoexec folder ของ executor
--! เช่น: autoexec/ntg_ui_loader.lua
-------------------------------------------------------------------------------

--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  วิธีใช้ AutoExec สำหรับระบบ Key System + Main Script      ║
    ╠══════════════════════════════════════════════════════════════╣
    ║                                                              ║
    ║  Flow การทำงาน:                                              ║
    ║  1. AutoExec → โหลด KeySystem.lua (มี platoboost ฝังอยู่)   ║
    ║  2. KeySystem ตรวจ cached key → ถ้า valid → โหลด MainScript  ║
    ║  3. ถ้า key expired → เปิด UI ให้กรอก key ใหม่               ║
    ║  4. Key valid → โหลด MainScript อัตโนมัติ                    ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
]]--

-------------------------------------------------------------------------------
--! วิธีที่ 1: โหลด KeySystem จาก URL (แนะนำ)
--! KeySystem.lua จะจัดการ key verification + โหลด main script ให้เอง
-------------------------------------------------------------------------------

loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/KeySystem.lua"))()

-- แค่นี้จบ! KeySystem.lua จะ:
-- ✅ ตรวจ cached key → ถ้ายัง valid → โหลด main script เลย
-- ✅ ถ้า key expired → เปิด UI ให้กรอก key ใหม่
-- ✅ key valid → โหลด main script อัตโนมัติ


-------------------------------------------------------------------------------
--! วิธีที่ 2: ใช้ร่วมกับ LuArmor (กรณีมี 2 ชั้นป้องกัน)
--! ตัวอย่างจากโจทย์: LuArmor + Platoboost Key System
-------------------------------------------------------------------------------
--[[

-- ชั้นที่ 1: LuArmor Authorization
_G.Authorize = "Cy2Z3eaTBvt7WN9joVTZto8JHPMT"
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/0fbaa2aa75e1ef5d4da3dd2e849494c8.lua"))()

-- หมายเหตุ: ถ้าใช้ LuArmor เป็นชั้นแรก ให้ LuArmor loader
-- โหลด KeySystem.lua เป็นสคริปต์ที่ถูก protect ไว้
-- เมื่อ LuArmor ผ่าน → KeySystem.lua ทำงาน → ตรวจ Platoboost key → โหลด main script

]]--


-------------------------------------------------------------------------------
--! วิธีที่ 3: วางโค้ดแบบสั้นที่สุด (1 บรรทัด)
-------------------------------------------------------------------------------

-- ถ้าไม่ต้องการ LuArmor:
-- loadstring(game:HttpGet("URL_TO_YOUR_KEYSYSTEM"))()

-- ถ้าต้องการ LuArmor + Platoboost:
-- _G.Authorize = "YOUR_LUARMOR_KEY"; loadstring(game:HttpGet("LUARMOR_LOADER_URL"))()


-------------------------------------------------------------------------------
--! ตัวอย่างการวางโครงสร้างจริง (สำหรับ production)
--!
--! ลำดับการทำงาน:
--!
--! [AutoExec] → [LuArmor Gate] → [KeySystem.lua (Platoboost)] → [script.lua]
--!     ↓              ↓                    ↓                         ↓
--!  executor     ตรวจ license       ตรวจ key + UI              สคริปต์หลัก
--!  auto-run     _G.Authorize       verifyKey()                ฟีเจอร์ทั้งหมด
--!
--! วิธีตั้งค่า:
--! 1. อัพโหลด KeySystem.lua ไปยัง LuArmor (protect ด้วย obfuscation)
--! 2. ตั้ง MAIN_SCRIPT ใน KeySystem.lua ให้ชี้ไปยัง script.lua ที่ protect แล้ว
--! 3. วาง autoexec ที่โหลด LuArmor loader
--!
--! autoexec/ntg_ui.lua:
--!   _G.Authorize = "Cy2Z3eaTBvt7WN9joVTZto8JHPMT"
--!   loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/0fbaa2aa75e1ef5d4da3dd2e849494c8.lua"))()
--!
-------------------------------------------------------------------------------
