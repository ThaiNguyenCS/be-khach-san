drop database if exists khach_san;
create database if not exists khach_san;
use khach_san;

CREATE TABLE IF NOT EXISTS ChiNhanh (
    MaChiNhanh VARCHAR(50) PRIMARY KEY,
    DiaChi VARCHAR(255),
    Hotline VARCHAR(20)
);


CREATE TABLE IF NOT EXISTS DichVuAnUong (
    MaDichVu VARCHAR(50) PRIMARY KEY,
    MucGia DOUBLE(10, 2),
    MoTa VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DichVuDuaDon (
    MaDichVu VARCHAR(50) PRIMARY KEY,
    LoaiXe VARCHAR(50),
    MucGia DOUBLE(10, 2),
    MoTa VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DichVuGiatUi (
    MaDichVu VARCHAR(50) PRIMARY KEY,
    TuyChonGiat VARCHAR(50),
    MucGia DOUBLE(10, 2),
    MoTa VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DichVuPhongHop (
    MaDichVu VARCHAR(50) PRIMARY KEY,
    SucChua INT,
    MucGia DOUBLE(10, 2),
    MoTa VARCHAR(255)
);

-- restrict cho thời gian bắt đầu < thời gian kết thúc
-- restrict cho phần trăm giảm giá <= 100%

CREATE TABLE IF NOT EXISTS ChuongTrinhGiamGia (
    MaGiamGia VARCHAR(50) PRIMARY KEY,
    ThoiGianBatDau DATETIME,
    ThoiGianKetThuc DATETIME,
    PhanTramGiamGia DECIMAL(5, 2), 
    check ( PhanTramGiamGia <= 100),
    check (thoigianbatdau <= thoigianketthuc)
);

-- Thêm domain constraint cho giới tính

CREATE TABLE IF NOT EXISTS KhachHang (
    ID VARCHAR(50) PRIMARY KEY,
    Ten VARCHAR(255),
    CCCD VARCHAR(12),
    SoDienThoai VARCHAR(15) UNIQUE,
    NgaySinh DATE,
    GioiTinh VARCHAR(10),
    Email VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS NhanVien (
    ID VARCHAR(50) PRIMARY KEY,
    HoTen VARCHAR(255) NOT NULL,
    GioiTinh ENUM ('Other','Male','Female') NOT NULL,
    Luong DECIMAL(18, 2),
    NgaySinh DATE NOT NULL,
	MaBHXH VARCHAR(15) UNIQUE,
	CCCD VARCHAR(12) UNIQUE NOT NULL,
    SoTaiKhoan VARCHAR(15),
	VaiTro ENUM('Manager', 'Receptionist', 'House Keeper', 'Room Employee', 'Other') DEFAULT 'Other',
    ThoiGianBatDauLamViec DATE,
    TrinhDoHocVan VARCHAR(255),
    MaChiNhanh VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS SoDienThoaiNhanVien (
    IDNhanVien VARCHAR(50),
    SoDienThoai VARCHAR(15),
    PRIMARY KEY (IDNhanVien, SoDienThoai)
);

CREATE TABLE IF NOT EXISTS NhanVienVeSinh (
    ID VARCHAR(50) PRIMARY KEY
); 

CREATE TABLE IF NOT EXISTS LeTan (
    ID VARCHAR(50) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS QuanLy (
    ID VARCHAR(50) PRIMARY KEY,
    MaChiNhanh VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS NhanVienPhong (
    ID VARCHAR(50) PRIMARY KEY
);

-- Thêm domain constraint cho loại LichSuSuaChuaBaoDuong (Đã thêm)
CREATE TABLE IF NOT EXISTS LichSuSuaChuaBaoDuong (
    ID VARCHAR(50) PRIMARY KEY,
    ChiPhi DECIMAL(18, 2) NOT NULL CHECK (ChiPhi >= 0),
    NgaySuaChua DATE NOT NULL,
    MoTa VARCHAR(255),
    Loai VARCHAR(50) CHECK (Loai IN ('Bảo dưỡng', 'Sửa chữa', 'Thay thế')),
    IDTienNghi_CoSoVatChat VARCHAR(50)
);

--  VD : máy lạnh, TV, giường,..
CREATE TABLE IF NOT EXISTS TienNghiPhong (
    ID VARCHAR(50) PRIMARY KEY,
    Ten VARCHAR(255) NOT NULL,
    MoTa TEXT
);

-- Quản lý thông tin tiện nghi ở cấp khách sạn (ví dụ: hồ bơi, phòng gym, nhà hàng).
CREATE TABLE IF NOT EXISTS TienNghiKhachSan (
    ID VARCHAR(50) PRIMARY KEY,
    Ten VARCHAR(255) NOT NULL,
    MaChiNhanh VARCHAR(50) NOT NULL,
    MoTa TEXT
);

CREATE TABLE IF NOT EXISTS BanBaoCaoPhong (
    ID VARCHAR(50) PRIMARY KEY,
    ThoiGian DATETIME,
    NoiDung VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS CoSoVatChatHuHao (
    ID VARCHAR(50) PRIMARY KEY,
    GiaDenBu DECIMAL(18, 2),
    MoTa VARCHAR(255),
    MaBanBaoCaoPhong VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Phong (
    MaPhong VARCHAR(50) PRIMARY KEY,
    MaChiNhanh VARCHAR(50),
    TrangThai ENUM ('in use', 'maintenance', 'empty') DEFAULT 'empty',
    LoaiPhong ENUM('normal', 'vip'),
    SoPhong INT NOT NULL,
    MoTa TEXT,
    IDNhanVienDonPhong VARCHAR(50),
    IDNhanVienPhong VARCHAR(50),
    IDGiamGia VARCHAR(50),
    SucChua INT DEFAULT 0,
    MaPhongLienKet VARCHAR(50),
	UNIQUE (SoPhong, MaChiNhanh)
);

CREATE TABLE IF NOT EXISTS DoTieuDung (
    ID VARCHAR(50) PRIMARY KEY,
    TenSanPham VARCHAR(255),
    SoLuong INT DEFAULT 0,
    GiaNhapDonVi DECIMAL(18, 2),
    GiaBanDonVi DECIMAL(18, 2)
   -- MaPhong VARCHAR(50),
   -- FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS DoTieuDung_Phong (
   MaDoTieuDung VARCHAR(50),
   SoLuong INT DEFAULT 0,
   MaPhong VARCHAR(50),
   PRIMARY KEY (MaDoTieuDung , MaPhong)
);

CREATE TABLE IF NOT EXISTS BangGia (
    ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    ThoiGianBatDauApDung DATETIME,
    ThoiGianKetThucApDung DATETIME,
    GiaThapNhat DECIMAL(18, 2),
    GiaCongBo DECIMAL(18, 2),
    MaPhong VARCHAR(50),
    UNIQUE(MaPhong, ThoiGianBatDauApDung),
    CHECK (GiaThapNhat <= GiaCongBo),
    CHECK (ThoiGianBatDauApDung <= ThoiGianKetThucApDung)
);

CREATE TABLE IF NOT EXISTS CoSoVatChatPhong (
    ID VARCHAR(50) PRIMARY KEY,
    TenTrangBi VARCHAR(255) NOT NULL,
    GiaMua DECIMAL(18, 2) NOT NULL CHECK (GiaMua >= 0),
    MaSanPham VARCHAR(50),
    TinhTrang VARCHAR(50) NOT NULL CHECK (TinhTrang IN ('broken', 'maintenance', 'good')),
    MaPhong VARCHAR(50),
    imageURL VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS TienNghiPhong_Phong (
    MaPhong VARCHAR(50),
    MaTienNghi VARCHAR(50),
    PRIMARY KEY (MaPhong, MaTienNghi)
);

CREATE TABLE IF NOT EXISTS DonDatPhong (
    MaDon VARCHAR(50) PRIMARY KEY,
    IDLeTan VARCHAR(50),
    IDKhachHang VARCHAR(50),
    ThoiGianDat DATETIME,
    TrangThaiDon ENUM('confirmed', 'not confirmed', 'cancelled'),
    NgayNhanPhong DATETIME,
    NgayTraPhong DATETIME,
    Nguon VARCHAR(255),
    SoTienDatCoc DECIMAL(18, 2),
    CHECK (ngaynhanphong <= ngaytraphong),
    CHECK(NgayNhanPhong > CURRENT_DATE())
);

CREATE TABLE IF NOT EXISTS BanGhiPhong (
    MaPhong VARCHAR(50),
    ThoiGianTaoBanGhiPhong DATETIME,
    MaDatPhong VARCHAR(50),
    IDBanBaoCao VARCHAR(50),
    GiaTien DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (MaPhong, ThoiGianTaoBanGhiPhong )
);

CREATE TABLE IF NOT EXISTS DonDatDichVuAnUong (
    MaDon VARCHAR(50) PRIMARY KEY,
    MaDichVu VARCHAR(50),
    MaPhong VARCHAR(50), -- PK_1 của BanGhiPhong
    ThoiGianTaoBanGhiPhong DATETIME, -- PK_2 của BanGhiPhong
    ThoiGian DATETIME,
    SoLuong INT,
    TongTien DECIMAL(10, 2), -- Tổng tiền của đơn
    TrangThai ENUM('cancelled', 'completed', 'not completed') -- Trạng thái đơn
);

CREATE TABLE IF NOT EXISTS DonSuDungDichVuGiatUi (
    MaDon VARCHAR(50) PRIMARY KEY,
    MaDichVu VARCHAR(50),
    MaPhong VARCHAR(50), -- PK_1 của BanGhiPhong
    ThoiGianTaoBanGhiPhong DATETIME, -- PK_2 của BanGhiPhong
    ThoiGian DATETIME,
    SoKg DECIMAL(10, 2),
    TongTien DECIMAL(10, 2), -- Tổng tiền của đơn
    TrangThai ENUM('cancelled', 'completed', 'not completed') -- Trạng thái đơn
);

CREATE TABLE IF NOT EXISTS DonSuDungDichVuDuaDon (
    MaDon VARCHAR(50) PRIMARY KEY,
    MaDichVu VARCHAR(50),
    MaPhong VARCHAR(50), -- PK_1 của BanGhiPhong
    ThoiGianTaoBanGhiPhong DATETIME, -- PK_2 của BanGhiPhong
    ThoiGian DATETIME,
    DiemDi VARCHAR(255),
    DiemDen VARCHAR(255),
    TongTien DECIMAL(10, 2), -- Tổng tiền của đơn
    TrangThai ENUM('cancelled', 'completed', 'not completed') -- Trạng thái đơn
);

CREATE TABLE IF NOT EXISTS DonSuDungDichVuPhongHop (
    MaDon VARCHAR(50) PRIMARY KEY,
    MaDichVu VARCHAR(50),
    MaPhong VARCHAR(50), -- PK_1 của BanGhiPhong
    ThoiGianTaoBanGhiPhong DATETIME, -- PK_2 của BanGhiPhong
    ThoiGian DATETIME,
    ThoiGianBatDau DATETIME,
    ThoiGianKetThuc DATETIME,
    TongTien DECIMAL(10, 2), -- Tổng tiền của đơn
    TrangThai ENUM('cancelled', 'completed', 'not completed'), -- Trạng thái đơn
    CHECK (ThoiGianBatDau < ThoiGianKetThuc)
);

CREATE TABLE IF NOT EXISTS DoiTuongGiamGia (
    ID VARCHAR(50) PRIMARY KEY,
    MaGiamGia VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS DichVuPhong (
    MaDichVu VARCHAR(50) PRIMARY KEY,
    MucGia DECIMAL(18, 2) NOT NULL,
    MoTa TEXT, -- mo ta xai text cho nhieu
    IDGiamGia VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS HoaDon (
    MaHoaDon VARCHAR(50) PRIMARY KEY,
    ThoiGianXuatHoaDon DATETIME,
    IDKhachHang VARCHAR(50) NOT NULL,
    MaDon VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS VatPhamSuDung (
    ID VARCHAR(50) PRIMARY KEY,
    SoLuong INT,
    Gia DECIMAL(18, 2), --  this is necessary because price in warehouse can changed 
    MaBanBaoCaoPhong VARCHAR(50)
);





ALTER TABLE NhanVien
ADD CONSTRAINT FKNV1
FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh) ON UPDATE CASCADE;

ALTER TABLE SoDienThoaiNhanVien
ADD CONSTRAINT FKSDTNV1
FOREIGN KEY (IDNhanVien) REFERENCES NhanVien(ID) ON UPDATE CASCADE;


ALTER TABLE NhanVienVeSinh
ADD CONSTRAINT FKNVVS1
FOREIGN KEY (ID) REFERENCES NhanVien(ID) ON UPDATE CASCADE;

ALTER TABLE LeTan
ADD CONSTRAINT FKNVLT1
FOREIGN KEY (ID) REFERENCES NhanVien(ID) ON UPDATE CASCADE;

ALTER TABLE QuanLy
ADD CONSTRAINT FKNVQL1
FOREIGN KEY (ID) REFERENCES NhanVien(ID) ON UPDATE CASCADE;

ALTER TABLE QuanLy
ADD CONSTRAINT FKNVQL2
FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh) ON UPDATE CASCADE;

ALTER TABLE NhanVienPhong
ADD CONSTRAINT FKNVP1
FOREIGN KEY (ID) REFERENCES NhanVien(ID) ON UPDATE CASCADE;

ALTER TABLE TienNghiKhachSan
ADD CONSTRAINT FKTNKS
FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE CoSoVatChatHuHao
ADD CONSTRAINT FKCSVCH
FOREIGN KEY (MaBanBaoCaoPhong) REFERENCES BanBaoCaoPhong(ID) ON UPDATE CASCADE;

ALTER TABLE Phong
ADD CONSTRAINT lien_ket_phong
FOREIGN KEY (MaPhongLienKet) REFERENCES Phong (MaPhong) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE Phong
ADD CONSTRAINT FKP1 
FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh) ON UPDATE CASCADE;

-- ALTER TABLE Phong
-- ADD CONSTRAINT FKP2 
-- FOREIGN KEY (IDNhanVienDonPhong) REFERENCES NhanVien(ID) ON UPDATE --CASCADE ON DELETE CASCADE;

-- ALTER TABLE Phong
-- ADD CONSTRAINT FKP3
-- FOREIGN KEY (IDNhanVienPhong) REFERENCES NhanVien(ID) ON UPDATE --CASCADE ON DELETE CASCADE;

ALTER TABLE Phong
ADD CONSTRAINT FKP4 
FOREIGN KEY (IDGiamGia) REFERENCES ChuongTrinhGiamGia(MaGiamGia) ON UPDATE CASCADE;

ALTER TABLE DoTieuDung_Phong
ADD CONSTRAINT FK_DoTieuDung1 
FOREIGN KEY (MaDoTieuDung) REFERENCES DoTieuDung(ID) ON UPDATE CASCADE;

ALTER TABLE DoTieuDung_Phong
ADD CONSTRAINT FK_DoTieuDung2 
FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong) ON UPDATE CASCADE;

ALTER TABLE BangGia
ADD CONSTRAINT FKBG
FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong) ON UPDATE CASCADE;

ALTER TABLE CoSoVatChatPhong
ADD CONSTRAINT FKCSVCP
FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE TienNghiPhong_Phong
ADD CONSTRAINT FKPTNP1
FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong) ON UPDATE CASCADE;

ALTER TABLE TienNghiPhong_Phong
ADD CONSTRAINT FKPTNP2
FOREIGN KEY (MaTienNghi) REFERENCES TienNghiPhong(ID) ON UPDATE CASCADE;

ALTER TABLE DonDatPhong
ADD CONSTRAINT FKDDP1
FOREIGN KEY (IDLeTan) REFERENCES LeTan(ID) ON UPDATE CASCADE;

ALTER TABLE DonDatPhong
ADD CONSTRAINT FKDDP2
FOREIGN KEY (IDKhachHang) REFERENCES KhachHang(ID) ON UPDATE CASCADE;

ALTER TABLE BanGhiPhong
ADD CONSTRAINT FKBGP1
FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong) ON UPDATE CASCADE;

ALTER TABLE BanGhiPhong
ADD CONSTRAINT FKBGP2
FOREIGN KEY (MaDatPhong) REFERENCES DonDatPhong(MaDon) ON UPDATE CASCADE;

ALTER TABLE BanGhiPhong
ADD CONSTRAINT FKBGP3
FOREIGN KEY (IDBanBaoCao) REFERENCES BanBaoCaoPhong(ID) ON UPDATE CASCADE;

ALTER TABLE DonDatDichVuAnUong
ADD CONSTRAINT FKDDDVAU1
FOREIGN KEY (MaDichVu) REFERENCES DichVuAnUong(MaDichVu) ON UPDATE CASCADE;

ALTER TABLE DonDatDichVuAnUong
ADD CONSTRAINT FKDDDVAU2
FOREIGN KEY (MaPhong, ThoiGianTaoBanGhiPhong) REFERENCES BanGhiPhong(MaPhong, ThoiGianTaoBanGhiPhong) ON UPDATE CASCADE;

ALTER TABLE DonSuDungDichVuGiatUi
ADD CONSTRAINT FKDDDVGU1
FOREIGN KEY (MaDichVu) REFERENCES DichVuGiatUi(MaDichVu) ON UPDATE CASCADE;

ALTER TABLE DonSuDungDichVuGiatUi
ADD CONSTRAINT FKDDDVGU2
FOREIGN KEY (MaPhong, ThoiGianTaoBanGhiPhong) REFERENCES BanGhiPhong(MaPhong, ThoiGianTaoBanGhiPhong) ON UPDATE CASCADE;

ALTER TABLE DonSuDungDichVuDuaDon
ADD CONSTRAINT FKDDDVDD1
FOREIGN KEY (MaDichVu) REFERENCES DichVuDuaDon(MaDichVu) ON UPDATE CASCADE;

ALTER TABLE DonSuDungDichVuDuaDon
ADD CONSTRAINT FKDDDVDD2
FOREIGN KEY (MaPhong, ThoiGianTaoBanGhiPhong) REFERENCES BanGhiPhong(MaPhong, ThoiGianTaoBanGhiPhong) ON UPDATE CASCADE;

ALTER TABLE DonSuDungDichVuPhongHop
ADD CONSTRAINT FKDDDVPH1
FOREIGN KEY (MaDichVu) REFERENCES DichVuPhongHop(MaDichVu) ON UPDATE CASCADE;

ALTER TABLE DonSuDungDichVuPhongHop
ADD CONSTRAINT FKDDDVPH2
FOREIGN KEY (MaPhong, ThoiGianTaoBanGhiPhong) REFERENCES BanGhiPhong(MaPhong, ThoiGianTaoBanGhiPhong) ON UPDATE CASCADE;

ALTER TABLE DoiTuongGiamGia
ADD CONSTRAINT FKDTGG2
FOREIGN KEY (MaGiamGia) REFERENCES ChuongTrinhGiamGia(MaGiamGia) ON UPDATE CASCADE;

ALTER TABLE DichVuPhong
ADD CONSTRAINT FKDVP2
FOREIGN KEY (IDGiamGia) REFERENCES DoiTuongGiamGia(ID) ON UPDATE CASCADE;

ALTER TABLE HoaDon
ADD CONSTRAINT FKHD1
FOREIGN KEY (IDKhachHang) REFERENCES KhachHang(ID) ON UPDATE CASCADE;

ALTER TABLE HoaDon
ADD CONSTRAINT FKHD2
FOREIGN KEY (MaDon) REFERENCES DonDatPhong(MaDon) ON UPDATE CASCADE;

ALTER TABLE VatPhamSuDung
ADD CONSTRAINT FKVPSD1
FOREIGN KEY (MaBanBaoCaoPhong) REFERENCES BanBaoCaoPhong(ID) ON UPDATE CASCADE;


-- trigger để check ngày đặt phòng

DELIMITER $$ 
CREATE TRIGGER check_order_date
BEFORE INSERT ON DonDatPhong
FOR EACH ROW
BEGIN
IF CURRENT_DATE() > DATE(NEW.NgayNhanPhong) THEN
   SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You cannot place an order in the past';
    END IF;
END $$
DELIMITER ;



-- trigger để check tuổi nhân viên 
DELIMITER $$
CREATE TRIGGER check_age_before_insert
BEFORE INSERT ON NhanVien
FOR EACH ROW
BEGIN
   IF TIMESTAMPDIFF(YEAR, NEW.NgaySinh, CURDATE()) <= 18 THEN
   SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee must be older than 18';
    END IF;
END $$
DELIMITER ;

-- Trigger Xóa các bản ghi khi CSVC bị xóa
DELIMITER $$

CREATE TRIGGER AfterDelete_CoSoVatChat
AFTER DELETE ON CoSoVatChatPhong
FOR EACH ROW
BEGIN
    DELETE FROM LichSuSuaChuaBaoDuong
    WHERE IDTienNghi_CoSoVatChat = OLD.ID;
END $$

DELIMITER ;

-- Trigger Check không được trùng tên TienNghiPhong
DELIMITER $$

CREATE TRIGGER BeforeInsert_TienNghiPhong
BEFORE INSERT ON TienNghiPhong
FOR EACH ROW
BEGIN
    DECLARE countTienNghi INT;
    SELECT COUNT(*) INTO countTienNghi 
    FROM TienNghiPhong 
    WHERE LOWER(Ten) = LOWER(NEW.Ten);

    IF countTienNghi > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tên tiện nghi đã tồn tại!';
    END IF;
END $$

DELIMITER ;




-- thủ tục tạo bảng giá sau khi tạo room

DELIMITER $$
CREATE PROCEDURE ThemTienNghiPhong (IN ID VARCHAR(50), IN MoTa TEXT, IN Ten VARCHAR(255))
BEGIN
    INSERT INTO TienNghiPhong (id, ten, mota) VALUES (ID, Ten, Mota);
END;$$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE 
InsertPriceListFor30Days(IN MaPhong VARCHAR(50), IN base_price DECIMAL(18,2))  
BEGIN 
DECLARE i INT DEFAULT 0; 
DECLARE start_date DATE DEFAULT CURDATE(); 
WHILE i < 30 DO 
INSERT INTO BangGia (MaPhong, ThoiGianBatDauApDung, ThoiGianKetThucApDung, GiaThapNhat, GiaCongBo) VALUES 
(MaPhong, DATE_ADD(start_date, INTERVAL i DAY), DATE_ADD(DATE_ADD(start_date, INTERVAL i DAY), INTERVAL '23:59:59' HOUR_SECOND), base_price, base_price + 100000); 
SET i = i + 1;
END WHILE; 
END
$$ 
DELIMITER ;




DELIMITER $$

CREATE PROCEDURE InsertDailyPricesByRoomType (
    IN selectedMonth INT,   -- The desired month (e.g., 1 for January)
    IN selectedYear INT,    -- The desired year (e.g., 2024)
    IN defaultGiaThapNhatNormal DECIMAL(18, 2), -- Default low price for normal rooms
    IN defaultGiaCongBoNormal DECIMAL(18, 2),   -- Default high price for normal rooms
    IN defaultGiaThapNhatVip DECIMAL(18, 2),    -- Default low price for VIP rooms
    IN defaultGiaCongBoVip DECIMAL(18, 2)       -- Default high price for VIP rooms
)
BEGIN
    DECLARE startDate DATE;
    DECLARE endDate DATE;
    DECLARE currentDate DATE;

    -- Calculate the start and end dates of the month
    SET startDate = MAKEDATE(selectedYear, 1) + INTERVAL (selectedMonth - 1) MONTH;
    SET endDate = LAST_DAY(startDate);
    SET currentDate = startDate;

    -- Loop through each day of the month
    WHILE currentDate <= endDate DO
        -- Insert records for all rooms for the current date if they do not already exist
        INSERT INTO BangGia (ThoiGianBatDauApDung, ThoiGianKetThucApDung, GiaThapNhat, GiaCongBo, MaPhong)
        SELECT 
            CONCAT(currentDate, ' 00:00:00') AS ThoiGianBatDauApDung,
            CONCAT(currentDate, ' 23:59:59') AS ThoiGianKetThucApDung,
            CASE 
                WHEN p.LoaiPhong = 'normal' THEN defaultGiaThapNhatNormal
                WHEN p.LoaiPhong = 'vip' THEN  defaultGiaThapNhatVip
            END AS GiaThapNhat,
            CASE 
                WHEN p.LoaiPhong = 'normal' THEN defaultGiaCongBoNormal
                WHEN p.LoaiPhong = 'vip' THEN  defaultGiaCongBoVip
            END AS GiaCongBo,
            p.MaPhong
        FROM 
            Phong p
        WHERE 
            NOT EXISTS (
                SELECT 1 
                FROM BangGia bg
                WHERE bg.MaPhong = p.MaPhong
                  AND bg.ThoiGianBatDauApDung = CONCAT(currentDate, ' 00:00:00')
                  AND bg.ThoiGianKetThucApDung = CONCAT(currentDate, ' 23:59:59')
            );

        -- Move to the next day
        SET currentDate = currentDate + INTERVAL 1 DAY;
    END WHILE;
END$$

DELIMITER ;

-- CALL InsertDailyPricesByRoomType(3, 2025, 500000, 600000, 1000000, 1200000);

-- Function procedure của LichSuSuaChuaBaoDuong

-- Function tính tổng chi phi sửa chữa của 1 CSVC

DELIMITER $$

CREATE FUNCTION TongChiPhiSuaChua(IDCoSoVatChat VARCHAR(50))
RETURNS DECIMAL(18, 2)
DETERMINISTIC
BEGIN
    DECLARE tongChiPhi DECIMAL(18, 2);
    SELECT SUM(ChiPhi)
    INTO tongChiPhi
    FROM LichSuSuaChuaBaoDuong
    WHERE IDTienNghi_CoSoVatChat = IDCoSoVatChat;
    RETURN COALESCE(tongChiPhi, 0);
END $$

DELIMITER ;


-- Tạo 1 procedure bản ghi LichSuSuaChuaBaoDuong
DELIMITER $$

CREATE PROCEDURE ThemLichSuaChua(
    IN p_ID VARCHAR(50),
    IN p_ChiPhi DECIMAL(18, 2),
    IN p_NgaySuaChua DATE,
    IN p_MoTa VARCHAR(255),
    IN p_Loai VARCHAR(50),
    IN p_IDTienNghi_CoSoVatChat VARCHAR(50)
)
BEGIN
    INSERT INTO LichSuSuaChuaBaoDuong (
        ID, ChiPhi, NgaySuaChua, MoTa, Loai, IDTienNghi_CoSoVatChat
    )
    VALUES (
        p_ID, p_ChiPhi, p_NgaySuaChua, p_MoTa, p_Loai, p_IDTienNghi_CoSoVatChat
    );
END $$

DELIMITER ;

-- CALL ThemLichSuaChua('ID1', 500000, '2024-12-01', 'Thay bóng đèn', 'Sửa chữa', 'ID_TienNghi1');




-- TienNghiPhong

-- CREATE Procedure TienNghiPhong (CALL CreateTienNghiPhong('TN001', 'Máy lạnh', 'Máy lạnh công suất cao 2HP');

)
DELIMITER $$

CREATE PROCEDURE CreateTienNghiPhong(
    IN p_ID VARCHAR(50),
    IN p_Ten VARCHAR(255),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    INSERT INTO TienNghiPhong (ID, Ten, MoTa)
    VALUES (p_ID, p_Ten, p_MoTa);
END $$

DELIMITER ;
-- READ Procedure TienNghiPhong (CALL GetAllTienNghiPhong();)
DELIMITER $$

CREATE PROCEDURE GetAllTienNghiPhong()
BEGIN
    SELECT * FROM TienNghiPhong;
END $$

DELIMITER ;

-- READ Procedure TienNghiPhong by ID (CALL GetTienNghiPhongByID('TN001');)


DELIMITER $$

CREATE PROCEDURE GetTienNghiPhongByID(
    IN p_ID VARCHAR(50)
)
BEGIN
    SELECT * FROM TienNghiPhong WHERE ID = p_ID;
END $$

DELIMITER ;









-- UPDATE Procedure TIenNghiPhong (CALL UpdateTienNghiPhong('TN001', 'Máy lạnh inverter', 'Máy lạnh tiết kiệm điện công suất 2HP');

)
DELIMITER $$

CREATE PROCEDURE UpdateTienNghiPhong(
    IN p_ID VARCHAR(50),
    IN p_TenMoi VARCHAR(255),
    IN p_MoTaMoi TEXT
)
BEGIN
    UPDATE TienNghiPhong
    SET Ten = p_TenMoi, MoTa = p_MoTaMoi
    WHERE ID = p_ID;
END $$
-- DELETE Procedure TIenNghiPhong CALL DeleteTienNghiPhong('TN001');

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE DeleteTienNghiPhong(
    IN p_ID VARCHAR(50)
)
BEGIN
    DELETE FROM TienNghiPhong WHERE ID = p_ID;
END $$

DELIMITER ;







-- CoSoVatChat

-- CREATE CSVC CALL CreateCoSoVatChatPhong('CSVC001', 'Tivi', 12000000, 'SP001', 'good', 'P001');


DELIMITER $$

CREATE PROCEDURE CreateCoSoVatChatPhong(
    IN p_ID VARCHAR(50),
    IN p_TenTrangBi VARCHAR(255),
    IN p_GiaMua DECIMAL(18, 2),
    IN p_MaSanPham VARCHAR(50),
    IN p_TinhTrang VARCHAR(50),
    IN p_MaPhong VARCHAR(50)
)
BEGIN
    INSERT INTO CoSoVatChatPhong (ID, TenTrangBi, GiaMua, MaSanPham, TinhTrang, MaPhong)
    VALUES (p_ID, p_TenTrangBi, p_GiaMua, p_MaSanPham, p_TinhTrang, p_MaPhong);
END $$

DELIMITER ;

-- GET ALL CSVC CALL GetAllCoSoVatChatPhong();



DELIMITER $$

CREATE PROCEDURE GetAllCoSoVatChatPhong()
BEGIN
    SELECT * FROM CoSoVatChatPhong;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE GetCoSoVatChatPhongByID(
    IN p_ID VARCHAR(50)
)
BEGIN
    SELECT * FROM CoSoVatChatPhong WHERE ID = p_ID;
END $$

DELIMITER ;

-- GET CSVC by ID_phong CALL CALL GetCoSoVatChatPhongByRoom('P001');



DELIMITER $$

CREATE PROCEDURE GetCoSoVatChatPhongByRoom(
    IN p_MaPhong VARCHAR(50)
)
BEGIN
    SELECT * FROM CoSoVatChatPhong WHERE MaPhong = p_MaPhong;
END $$

DELIMITER ;
-- UPDATE CSVC CALL UpdateCoSoVatChatPhong('CSVC001', 'Smart TV', 15000000, 'maintenance', 'P002');



DELIMITER $$

CREATE PROCEDURE UpdateCoSoVatChatPhong(
    IN p_ID VARCHAR(50),
    IN p_TenTrangBiMoi VARCHAR(255),
    IN p_GiaMuaMoi DECIMAL(18, 2),
    IN p_TinhTrangMoi VARCHAR(50),
    IN p_MaPhongMoi VARCHAR(50)
)
BEGIN
    UPDATE CoSoVatChatPhong
    SET 
        TenTrangBi = p_TenTrangBiMoi, 
        GiaMua = p_GiaMuaMoi, 
        TinhTrang = p_TinhTrangMoi, 
        MaPhong = p_MaPhongMoi
    WHERE ID = p_ID;
END $$

DELIMITER ;

-- DELETE CSVC CALL DeleteCoSoVatChatPhong('CSVC001');



DELIMITER $$

CREATE PROCEDURE DeleteCoSoVatChatPhong(
    IN p_ID VARCHAR(50)
)
BEGIN
    DELETE FROM CoSoVatChatPhong WHERE ID = p_ID;
END $$

DELIMITER ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


DELIMITER $$
CREATE PROCEDURE CreateDichVuAnUong(
    IN p_MaDichVu VARCHAR(50),
    IN p_MucGia DOUBLE(10, 2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    INSERT INTO DichVuAnUong (MaDichVu, MucGia, MoTa )
    VALUES (p_MaDichVu, p_MucGia, p_Mota);
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetAllDichVuAnUong()
BEGIN
    SELECT * FROM DichVuAnUong;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetDichVuAnUongByID(
    IN p_ID VARCHAR(50)
)
BEGIN
    SELECT * FROM DichVuAnUong WHERE MaDichVu  = p_ID;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE UpdateDichVuAnUong(
    IN p_MaDichVu VARCHAR(50),
    IN p_MucGia DOUBLE(10,2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    UPDATE DichVuAnUong 
    SET
        MucGia = COALESCE(p_MucGia, MucGia),
        MoTa = COALESCE(p_MoTa, MoTa)
    WHERE MaDichVu = p_MaDichVu;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE DeleteDichVuAnUong (
    IN p_ID VARCHAR(50)
)
BEGIN
    DELETE FROM DichVuAnUong  WHERE MaDichVu  = p_ID;
END $$
DELIMITER ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


DELIMITER $$
CREATE PROCEDURE CreateDichVuDuaDon(
    IN p_MaDichVu VARCHAR(50),
    IN p_LoaiXe VARCHAR(50),
    IN p_MucGia DOUBLE(10,2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    INSERT INTO DichVuDuaDon (MaDichVu, LoaiXe, MucGia, MoTa)
    VALUES (p_MaDichVu, p_LoaiXe, p_MucGia, p_MoTa );
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetAllDichVuDuaDon()
BEGIN
    SELECT * FROM DichVuDuaDon ;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetDichVuDuaDonByID(
    IN p_ID VARCHAR(50)
)
BEGIN
    SELECT * FROM DichVuDuaDon WHERE MaDichVu = p_ID;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE UpdateDichVuDuaDon(
    IN p_MaDichVu VARCHAR(50),
    IN p_LoaiXe VARCHAR(50),
    IN p_MucGia DOUBLE(10,2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    UPDATE DichVuDuaDon 
    SET 
        LoaiXe = COALESCE(p_LoaiXe, LoaiXe),
        MucGia = COALESCE(p_MucGia, MucGia),
        MoTa = COALESCE(p_MoTa, MoTa)
    WHERE MaDichVu = p_MaDichVu;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE DeleteDichVuDuaDon(
    IN p_ID VARCHAR(50)
)
BEGIN
    DELETE FROM DichVuDuaDon WHERE MaDichVu = p_ID;
END $$
DELIMITER ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


DELIMITER $$
CREATE PROCEDURE CreateDichVuGiatUi(
    IN p_MaDichVu VARCHAR(50),
    IN p_TuyChonGiat VARCHAR(50),
    IN p_MucGia DOUBLE(10,2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    INSERT INTO DichVuGiatUi (MaDichVu, TuyChonGiat, MucGia, MoTa)
    VALUES (p_MaDichVu, p_TuyChonGiat, p_MucGia, p_MoTa );
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetAllDichVuGiatUi()
BEGIN
    SELECT * FROM DichVuGiatUi ;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetDichVuGiatUiByID(
    IN p_ID VARCHAR(50)
)
BEGIN
    SELECT * FROM DichVuGiatUi WHERE MaDichVu = p_ID;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE UpdateDichVuGiatUi(
    IN p_MaDichVu VARCHAR(50),
    IN p_TuyChonGiat VARCHAR(50),
    IN p_MucGia DOUBLE(10,2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    UPDATE DichVuGiatUi 
    SET 
        TuyChonGiat = COALESCE(p_TuyChonGiat, TuyChonGiat),
        MucGia = COALESCE(p_MucGia, MucGia),
        MoTa = COALESCE(p_MoTa, MoTa)
    WHERE MaDichVu = p_MaDichVu;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE DeleteDichVuGiatUi(
    IN p_ID VARCHAR(50)
)
BEGIN
    DELETE FROM DichVuGiatUi WHERE MaDichVu = p_ID;
END $$
DELIMITER ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


DELIMITER $$
CREATE PROCEDURE CreateDichVuPhongHop(
    IN p_MaDichVu VARCHAR(50),
    IN p_SucChua INT,
    IN p_MucGia DOUBLE(10,2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    INSERT INTO DichVuPhongHop (MaDichVu, SucChua, MucGia, MoTa)
    VALUES (p_MaDichVu, p_SucChua, p_MucGia, p_Mota);
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetAllDichVuPhongHop()
BEGIN
    SELECT * FROM DichVuPhongHop ;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetDichVuPhongHopID(
    IN p_ID VARCHAR(50)
)
BEGIN
    SELECT * FROM DichVuPhongHop WHERE MaDichVu = p_ID;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE UpdateDichVuPhongHop(
    IN p_MaDichVu VARCHAR(50),
    IN p_SucChua VARCHAR(255),
    IN p_MucGia DOUBLE(10,2),
    IN p_MoTa VARCHAR(255)
)
BEGIN
    UPDATE DichVuPhongHop 
    SET 
        SucChua = COALESCE(p_SucChua, SucChua),
        MucGia = COALESCE(p_MucGia, MucGia),
        MoTa = COALESCE(p_MoTa, MoTa)
    WHERE MaDichVu = p_MaDichVu;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE DeleteDichVuPhongHop(
    IN p_ID VARCHAR(50)
)
BEGIN
    DELETE FROM DichVuPhongHop WHERE MaDichVu = p_ID;
END $$
DELIMITER ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

DELIMITER $$

-- INSERT
CREATE PROCEDURE CreateDonDatDichVuAnUong(
    IN p_MaDon VARCHAR(50),
    IN p_MaDichVu VARCHAR(50),
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME,
    IN p_ThoiGian DATETIME,
    IN p_SoLuong INT,
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed'),
    IN p_TongTien DECIMAL(10, 2)
)
BEGIN
    INSERT INTO DonDatDichVuAnUong (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, SoLuong, TrangThai, TongTien)
    VALUES (p_MaDon, p_MaDichVu, p_MaPhong, p_ThoiGianTaoBanGhiPhong, p_ThoiGian, p_SoLuong, p_TrangThai, p_TongTien);
END $$

-- SELECT ALL
CREATE PROCEDURE GetAllDonDatDichVuAnUong()
BEGIN
    SELECT * FROM DonDatDichVuAnUong;
END $$

-- SELECT BY ID
CREATE PROCEDURE GetDonDatDichVuAnUongByID(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    SELECT * FROM DonDatDichVuAnUong WHERE MaDon = p_MaDon;
END $$

CREATE PROCEDURE GetDonDatDichVuAnUongByMaPhongAndThoiGianTaoBanGhiPhong(
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME
)
BEGIN
    SELECT * 
    FROM DonDatDichVuAnUong 
    WHERE MaPhong = p_MaPhong 
    AND ThoiGianTaoBanGhiPhong = p_ThoiGianTaoBanGhiPhong;
END $$

-- UPDATE
CREATE PROCEDURE UpdateDonDatDichVuAnUong(
    IN p_MaDon VARCHAR(50),
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed'),
    IN p_SoLuong INT,
    IN p_TongTien DECIMAL(10, 2)
)
BEGIN
    UPDATE DonDatDichVuAnUong
    SET TrangThai = COALESCE(p_TrangThai, TrangThai), 
        SoLuong = COALESCE(p_SoLuong, SoLuong), 
        TongTien = COALESCE(p_TongTien, TongTien)
    WHERE MaDon = p_MaDon;
END $$


-- DELETE
CREATE PROCEDURE DeleteDonDatDichVuAnUong(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    DELETE FROM DonDatDichVuAnUong WHERE MaDon = p_MaDon;
END $$

DELIMITER ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


DELIMITER $$

-- INSERT
CREATE PROCEDURE CreateDonSuDungDichVuDuaDon(
    IN p_MaDon VARCHAR(50),
    IN p_MaDichVu VARCHAR(50),
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME,
    IN p_ThoiGian DATETIME,
    IN p_DiemDi VARCHAR(255),
    IN p_DiemDen VARCHAR(255),
    IN p_TongTien DECIMAL(10, 2),
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed')
)
BEGIN
    INSERT INTO DonSuDungDichVuDuaDon (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, DiemDi, DiemDen, TongTien, TrangThai)
    VALUES (p_MaDon, p_MaDichVu, p_MaPhong, p_ThoiGianTaoBanGhiPhong, p_ThoiGian, p_DiemDi, p_DiemDen, p_TongTien, p_TrangThai);
END $$

-- SELECT ALL
CREATE PROCEDURE GetAllDonSuDungDichVuDuaDon()
BEGIN
    SELECT * FROM DonSuDungDichVuDuaDon;
END $$

-- SELECT BY ID
CREATE PROCEDURE GetDonSuDungDichVuDuaDonByID(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    SELECT * FROM DonSuDungDichVuDuaDon WHERE MaDon = p_MaDon;
END $$

CREATE PROCEDURE GetDonSuDungDichVuDuaDonByMaPhongAndThoiGianTaoBanGhiPhong(
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME
)
BEGIN
    SELECT * 
    FROM DonSuDungDichVuDuaDon 
    WHERE MaPhong = p_MaPhong 
    AND ThoiGianTaoBanGhiPhong = p_ThoiGianTaoBanGhiPhong;
END $$

-- UPDATE
CREATE PROCEDURE UpdateDonSuDungDichVuDuaDon(
    IN p_MaDon VARCHAR(50),
    IN p_DiemDi VARCHAR(255),
    IN p_DiemDen VARCHAR(255),
    IN p_TongTien DECIMAL(10, 2),
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed')
)
BEGIN
    UPDATE DonSuDungDichVuDuaDon
    SET DiemDi = COALESCE(p_DiemDi, DiemDi), 
        DiemDen = COALESCE(p_DiemDen, DiemDen), 
        TongTien = COALESCE(p_TongTien, TongTien), 
        TrangThai = COALESCE(p_TrangThai, TrangThai)
    WHERE MaDon = p_MaDon;
END $$

-- DELETE
CREATE PROCEDURE DeleteDonSuDungDichVuDuaDon(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    DELETE FROM DonSuDungDichVuDuaDon WHERE MaDon = p_MaDon;
END $$

DELIMITER ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


DELIMITER $$

-- INSERT
CREATE PROCEDURE CreateDonSuDungDichVuPhongHop(
    IN p_MaDon VARCHAR(50),
    IN p_MaDichVu VARCHAR(50),
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME,
    IN p_ThoiGian DATETIME,
    IN p_ThoiGianBatDau DATETIME,
    IN p_ThoiGianKetThuc DATETIME,
    IN p_TongTien DECIMAL(10, 2),
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed')
)
BEGIN
    INSERT INTO DonSuDungDichVuPhongHop (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, ThoiGianBatDau, ThoiGianKetThuc, TongTien, TrangThai)
    VALUES (p_MaDon, p_MaDichVu, p_MaPhong, p_ThoiGianTaoBanGhiPhong, p_ThoiGian, p_ThoiGianBatDau, p_ThoiGianKetThuc, p_TongTien, p_TrangThai);
END $$

-- SELECT ALL
CREATE PROCEDURE GetAllDonSuDungDichVuPhongHop()
BEGIN
    SELECT * FROM DonSuDungDichVuPhongHop;
END $$

-- SELECT BY ID
CREATE PROCEDURE GetDonSuDungDichVuPhongHopByID(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    SELECT * FROM DonSuDungDichVuPhongHop WHERE MaDon = p_MaDon;
END $$

CREATE PROCEDURE GetDonSuDungDichVuPhongHopByMaPhongAndThoiGianTaoBanGhiPhong(
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME
)
BEGIN
    SELECT * 
    FROM DonSuDungDichVuPhongHop 
    WHERE MaPhong = p_MaPhong 
    AND ThoiGianTaoBanGhiPhong = p_ThoiGianTaoBanGhiPhong;
END $$

-- UPDATE
CREATE PROCEDURE UpdateDonSuDungDichVuPhongHop(
    IN p_MaDon VARCHAR(50),
    IN p_ThoiGianBatDau DATETIME,
    IN p_ThoiGianKetThuc DATETIME,
    IN p_TongTien DECIMAL(10, 2),
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed')
)
BEGIN
    UPDATE DonSuDungDichVuPhongHop
    SET ThoiGianBatDau = COALESCE(p_ThoiGianBatDau, ThoiGianBatDau), 
        ThoiGianKetThuc = COALESCE(p_ThoiGianKetThuc, ThoiGianKetThuc), 
        TongTien = COALESCE(p_TongTien, TongTien), 
        TrangThai = COALESCE(p_TrangThai, TrangThai)
    WHERE MaDon = p_MaDon;
END $$


-- DELETE
CREATE PROCEDURE DeleteDonSuDungDichVuPhongHop(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    DELETE FROM DonSuDungDichVuPhongHop WHERE MaDon = p_MaDon;
END $$

DELIMITER ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

DELIMITER $$

-- INSERT
CREATE PROCEDURE CreateDonSuDungDichVuGiatUi(
    IN p_MaDon VARCHAR(50),
    IN p_MaDichVu VARCHAR(50),
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME,
    IN p_ThoiGian DATETIME,
    IN p_SoKg DECIMAL(10, 2),
    IN p_TongTien DECIMAL(10, 2),
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed')
)
BEGIN
    INSERT INTO DonSuDungDichVuGiatUi (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, SoKg, TongTien, TrangThai)
    VALUES (p_MaDon, p_MaDichVu, p_MaPhong, p_ThoiGianTaoBanGhiPhong, p_ThoiGian, p_SoKg, p_TongTien, p_TrangThai);
END $$

-- SELECT ALL
CREATE PROCEDURE GetAllDonSuDungDichVuGiatUi()
BEGIN
    SELECT * FROM DonSuDungDichVuGiatUi;
END $$

-- SELECT BY ID
CREATE PROCEDURE GetDonSuDungDichVuGiatUiByID(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    SELECT * FROM DonSuDungDichVuGiatUi WHERE MaDon = p_MaDon;
END $$


CREATE PROCEDURE GetDonSuDungDichVuGiatUiByMaPhongAndThoiGianTaoBanGhiPhong(
    IN p_MaPhong VARCHAR(50),
    IN p_ThoiGianTaoBanGhiPhong DATETIME
)
BEGIN
    SELECT * 
    FROM DonSuDungDichVuGiatUi 
    WHERE MaPhong = p_MaPhong 
    AND ThoiGianTaoBanGhiPhong = p_ThoiGianTaoBanGhiPhong;
END $$

-- UPDATE
CREATE PROCEDURE UpdateDonSuDungDichVuGiatUi(
    IN p_MaDon VARCHAR(50),
    IN p_SoKg DECIMAL(10, 2),
    IN p_TongTien DECIMAL(10, 2),
    IN p_TrangThai ENUM('cancelled', 'completed', 'not completed')
)
BEGIN
    UPDATE DonSuDungDichVuGiatUi
    SET SoKg = COALESCE(p_SoKg, SoKg),
        TongTien = COALESCE(p_TongTien, TongTien),
        TrangThai = COALESCE(p_TrangThai, TrangThai)
    WHERE MaDon = p_MaDon;
END $$


-- DELETE
CREATE PROCEDURE DeleteDonSuDungDichVuGiatUi(
    IN p_MaDon VARCHAR(50)
)
BEGIN
    DELETE FROM DonSuDungDichVuGiatUi WHERE MaDon = p_MaDon;
END $$

DELIMITER ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


-- Procedure: Thêm nhân viên 
DELIMITER $$

CREATE PROCEDURE InsertNhanVien(
    IN p_ID VARCHAR(50),
    IN p_HoTen VARCHAR(255),
    IN p_GioiTinh ENUM('Other', 'Male', 'Female'),
    IN p_Luong DECIMAL(18, 2),
    IN p_NgaySinh DATE,
    IN p_MaBHXH VARCHAR(15) ,
    IN p_CCCD VARCHAR(12),
    IN p_SoTaiKhoan VARCHAR(15) ,
    IN p_VaiTro ENUM('Manager', 'Receptionist', 'House Keeper', 'Room Employee', 'Other'),
    IN p_ThoiGianBatDauLamViec DATE ,
    IN p_TrinhDoHocVan VARCHAR(255),
    IN p_MaChiNhanh VARCHAR(50)
)
BEGIN
    INSERT INTO NhanVien (
        ID, HoTen, GioiTinh, Luong, NgaySinh, MaBHXH, CCCD, SoTaiKhoan, VaiTro, ThoiGianBatDauLamViec, TrinhDoHocVan, MaChiNhanh
    ) VALUES (
        p_ID, p_HoTen, p_GioiTinh, p_Luong, p_NgaySinh, 
        IFNULL(p_MaBHXH, NULL), 
        p_CCCD, 
        IFNULL(p_SoTaiKhoan, NULL), 
        IFNULL(p_VaiTro, 'Other'), 
        IFNULL(p_ThoiGianBatDauLamViec, NULL), 
        IFNULL(p_TrinhDoHocVan, NULL), 
        IFNULL(p_MaChiNhanh, NULL)
    );
END $$

DELIMITER ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

DELIMITER $$

CREATE PROCEDURE CreateBooking(
    IN cusPhoneNumber VARCHAR(15),
    IN cusId CHAR(36),
    IN cusName VARCHAR(255),
    IN cusCitizenId VARCHAR(20),
    IN cusDOB DATE,
    IN cusSex VARCHAR(10),
    IN orderId CHAR(36),
    IN roomId CHAR(36),
    IN checkInDate DATE,
    IN checkOutDate DATE,
    IN deposit DECIMAL(10, 2)
)
BEGIN
    DECLARE existingCustomerId CHAR(36);
    DECLARE TotalGiaSauGiam DECIMAL(10, 2);
    DECLARE exit handler for SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    -- Start transaction
    START TRANSACTION;

    SELECT ID INTO existingCustomerId
    FROM KhachHang
    WHERE SoDienThoai = cusPhoneNumber
    LIMIT 1;

    IF existingCustomerId IS NULL THEN
        SET existingCustomerId = cusId;
        INSERT INTO KhachHang (ID, Ten, CCCD, SoDienThoai, NgaySinh, GioiTinh)
        VALUES (cusId, cusName, cusCitizenId, cusPhoneNumber, cusDOB, cusSex);
    END IF;

    INSERT INTO DonDatPhong (MaDon, IDKhachHang, ThoiGianDat, TrangThaiDon, NgayNhanPhong, NgayTraPhong, Nguon, SoTienDatCoc)
    VALUES (orderId, existingCustomerId, NOW(), 'not confirmed', checkInDate, checkOutDate, 'Website', deposit);

    WITH RoomInfo AS (
        SELECT IDGiamGia 
        FROM Phong 
        WHERE MaPhong = roomId
        LIMIT 1
    ),
    PriceInfo AS (
        SELECT * 
        FROM BangGia 
        WHERE MaPhong = roomId
          AND NOT (
             ThoiGianKetThucApDung < checkInDate OR ThoiGianBatDauApDung > checkOutDate
          )
    ),
    DiscountInfo AS (
        SELECT *
        FROM ChuongTrinhGiamGia
        WHERE MaGiamGia = (SELECT IDGiamGia FROM RoomInfo)
    )
    SELECT 
        SUM(CASE 
                WHEN p.ThoiGianBatDauApDung BETWEEN d.ThoiGianBatDau AND d.ThoiGianKetThuc THEN p.GiaCongBo * (1 - d.PhanTramGiamGia / 100)
                ELSE p.GiaCongBo
            END
        ) INTO TotalGiaSauGiam
    FROM PriceInfo p
    LEFT JOIN DiscountInfo d ON 1=1;

    UPDATE Phong
    SET IDGiamGia = NULL
    WHERE MaPhong = roomId;

    INSERT INTO BanGhiPhong (MaPhong, ThoiGianTaoBanGhiPhong, MaDatPhong, GiaTien)
    VALUES (roomId, NOW(), orderId, TotalGiaSauGiam);

    -- Commit the transaction if everything succeeds
    COMMIT;
END $$

DELIMITER ;





INSERT INTO ChiNhanh (MaChiNhanh, DiaChi, Hotline)
VALUES
('CN01', 'Điện Biên Phủ', '01234567890'),
('CN02', 'Bà Huyện Thanh Quan', '0919123456');

INSERT INTO Phong (MaPhong, MaChiNhanh, TrangThai, LoaiPhong, SoPhong, MoTa, IDNhanVienDonPhong, IDNhanVienPhong, IDGiamGia, SucChua, MaPhongLienKet) VALUES ('1ef2149f-2f72-4e3c-9c35-3a049e62d8ff', 'CN01', 'empty', 'normal', 101, NULL, NULL, NULL, NULL, 2, NULL), ('8cb5652e-3613-41a7-9f33-0549dcb1adce', 'CN01', 'empty', 'normal', 102, NULL, NULL, NULL, NULL, 2, NULL), ('e9fd906e-5655-4cf6-8d4f-7d4556243114', 'CN01', 'empty', 'vip', 103, NULL, NULL, NULL, NULL, 2, NULL), ('8627801c-f14d-4a86-844e-73163eac571a', 'CN01', 'empty', 'normal', 104, NULL, NULL, NULL, NULL, 2, NULL), ('a250f35d-5818-40bd-9def-9056a4f7f3ce', 'CN01', 'empty', 'vip', 105, NULL, NULL, NULL, NULL, 2, NULL), ('a868b143-d2a3-48c8-a9e0-1ddd17f89441', 'CN01', 'empty', 'normal', 106, NULL, NULL, NULL, NULL, 2, NULL), ('9987b36d-7dce-4d3b-971c-f951096545d4', 'CN01', 'empty', 'normal', 107, NULL, NULL, NULL, NULL, 2, NULL), ('08c9f188-457a-451d-91cc-81f51af8b92f', 'CN01', 'empty', 'normal', 108, NULL, NULL, NULL, NULL, 2, NULL), ('f0c77063-f713-4b0f-94ad-4327b41a54b7', 'CN01', 'empty', 'vip', 109, NULL, NULL, NULL, NULL, 2, NULL), ('73e69a97-3b87-4f19-9286-5013037cf94d', 'CN01', 'empty', 'normal', 110, NULL, NULL, NULL, NULL, 2, NULL), ('9eb60dc2-fccb-4c23-803a-a3914e359f13', 'CN01', 'empty', 'vip', 111, NULL, NULL, NULL, NULL, 2, NULL), ('1df5902e-2795-4c0e-a6c1-45d69abf7d5c', 'CN01', 'empty', 'normal', 112, NULL, NULL, NULL, NULL, 2, NULL), ('26281e30-03c0-44cf-9dc7-fc3b772b82a7', 'CN01', 'empty', 'vip', 113, NULL, NULL, NULL, NULL, 2, NULL), ('fe6f4efe-6553-4d8c-b895-80fa27246d20', 'CN01', 'empty', 'normal', 114, NULL, NULL, NULL, NULL, 2, NULL), ('987c8df6-4171-410b-97da-34c8de21dffa', 'CN01', 'empty', 'normal', 115, NULL, NULL, NULL, NULL, 2, NULL), ('632b2417-2af6-40a0-ab65-25d21e2d3861', 'CN01', 'empty', 'normal', 116, NULL, NULL, NULL, NULL, 2, NULL), ('d61af8de-2636-48bf-bfb2-a7ba4c331dff', 'CN01', 'empty', 'vip', 117, NULL, NULL, NULL, NULL, 2, NULL), ('a958254a-24e9-4fff-bfe6-7040b569b9d0', 'CN01', 'empty', 'normal', 118, NULL, NULL, NULL, NULL, 2, NULL), ('e57a204f-23d1-460c-ac07-69281e82b2f4', 'CN01', 'empty', 'normal', 119, NULL, NULL, NULL, NULL, 2, NULL), ('48c6ef9e-37eb-4ba2-9c2d-f78bd3a2ead6', 'CN01', 'empty', 'normal', 120, NULL, NULL, NULL, NULL, 2, NULL), ('019f2ab2-b53b-4d53-b772-0f7e1d48c4a6', 'CN01', 'empty', 'normal', 201, NULL, NULL, NULL, NULL, 2, NULL), ('25c3f188-c0a5-4204-b19b-0122f7934346', 'CN01', 'empty', 'normal', 202, NULL, NULL, NULL, NULL, 2, NULL), ('8a45b9a2-a878-45d5-b44c-1d0ba1198cdc', 'CN01', 'empty', 'normal', 203, NULL, NULL, NULL, NULL, 2, NULL), ('7be0476c-eb64-44f3-83af-c2ca66fedce9', 'CN01', 'empty', 'vip', 204, NULL, NULL, NULL, NULL, 2, NULL), ('e5b1450f-b40e-4eed-a4d4-5523aa4b5f3b', 'CN01', 'empty', 'normal', 205, NULL, NULL, NULL, NULL, 2, NULL), ('8f21ec70-3804-4b6e-82c4-c281c63bd367', 'CN01', 'empty', 'normal', 206, NULL, NULL, NULL, NULL, 2, NULL), ('7ca6f209-fce2-4964-be46-c6c75829ba3f', 'CN01', 'empty', 'normal', 207, NULL, NULL, NULL, NULL, 2, NULL), ('b288415f-d11e-45a8-bd66-cf04fd98cf80', 'CN01', 'empty', 'normal', 208, NULL, NULL, NULL, NULL, 2, NULL), ('3e091c8c-945a-4d6f-bc8d-f99b55aad2c2', 'CN01', 'empty', 'normal', 209, NULL, NULL, NULL, NULL, 2, NULL), ('339f11ff-91e1-4a8d-b1c2-f56b8a50fc74', 'CN01', 'empty', 'vip', 210, NULL, NULL, NULL, NULL, 2, NULL), ('ed817e6f-1358-4167-9db7-8cf2531f3e53', 'CN01', 'empty', 'normal', 211, NULL, NULL, NULL, NULL, 2, NULL), ('54c627b4-887b-4c17-a7d8-7afcd43b7db2', 'CN01', 'empty', 'normal', 212, NULL, NULL, NULL, NULL, 2, NULL), ('4ab7809f-e764-4df8-948c-b1e4164a1245', 'CN01', 'empty', 'vip', 213, NULL, NULL, NULL, NULL, 2, NULL), ('982beab5-2431-4f54-b826-5ac794449cd2', 'CN01', 'empty', 'normal', 214, NULL, NULL, NULL, NULL, 2, NULL), ('0a6e8fbf-00de-4756-bc05-a44fe89e09a8', 'CN01', 'empty', 'normal', 215, NULL, NULL, NULL, NULL, 2, NULL), ('0ef0294d-af49-46fd-a2aa-46d2c919ab4b', 'CN01', 'empty', 'normal', 216, NULL, NULL, NULL, NULL, 2, NULL), ('6dc76e97-f347-4f1b-a391-da38ad26ca92', 'CN01', 'empty', 'normal', 217, NULL, NULL, NULL, NULL, 2, NULL), ('19a6bbe3-553a-4f25-82dd-2871213f9c8b', 'CN01', 'empty', 'normal', 218, NULL, NULL, NULL, NULL, 2, NULL), ('a6024b97-08e1-4631-9a17-7db7dbb76761', 'CN01', 'empty', 'normal', 219, NULL, NULL, NULL, NULL, 2, NULL), ('6c2fc256-2bd0-4c6d-a4fa-68d386e11523', 'CN01', 'empty', 'normal', 220, NULL, NULL, NULL, NULL, 2, NULL), ('5b603c38-1b6f-4f95-a796-4ced6600fdf8', 'CN01', 'empty', 'normal', 301, NULL, NULL, NULL, NULL, 2, NULL), ('3a3b6b6f-396c-447d-bb9f-77bf1bd56266', 'CN01', 'empty', 'normal', 302, NULL, NULL, NULL, NULL, 2, NULL), ('a3e3792b-7439-4237-a903-ffe8dd24b5eb', 'CN01', 'empty', 'normal', 303, NULL, NULL, NULL, NULL, 2, NULL), ('c0e09f3d-a6cd-4305-8a9d-6b40434c8c51', 'CN01', 'empty', 'vip', 304, NULL, NULL, NULL, NULL, 2, NULL), ('8dd30ed1-22ff-45ab-8067-b65f9d8d4ff8', 'CN01', 'empty', 'vip', 305, NULL, NULL, NULL, NULL, 2, NULL), ('51d291d5-844a-4f12-b9d8-98d72ca468d3', 'CN01', 'empty', 'normal', 306, NULL, NULL, NULL, NULL, 2, NULL), ('9d37e0f6-3981-4fe6-82f7-204e739c762e', 'CN01', 'empty', 'normal', 307, NULL, NULL, NULL, NULL, 2, NULL), ('65ab4f2d-251d-4bcf-8d10-13b215a82cb2', 'CN01', 'empty', 'normal', 308, NULL, NULL, NULL, NULL, 2, NULL), ('2e31cb4b-11d8-4c24-8be3-c2ebf47ea6fe', 'CN01', 'empty', 'normal', 309, NULL, NULL, NULL, NULL, 2, NULL), ('420c9af0-63f1-4e8d-a619-e39425bd621f', 'CN01', 'empty', 'normal', 310, NULL, NULL, NULL, NULL, 2, NULL), ('adaab164-cb3e-4c38-8665-4f87557fc73f', 'CN01', 'empty', 'vip', 311, NULL, NULL, NULL, NULL, 2, NULL), ('68834c21-9d0a-4ac0-803a-c07d1a57cc85', 'CN01', 'empty', 'normal', 312, NULL, NULL, NULL, NULL, 2, NULL), ('6ccd9968-eb06-4647-942c-82ca7590b756', 'CN01', 'empty', 'normal', 313, NULL, NULL, NULL, NULL, 2, NULL), ('57280b0e-6dab-4592-8288-ff684955d6bc', 'CN01', 'empty', 'normal', 314, NULL, NULL, NULL, NULL, 2, NULL), ('54804511-0e29-424d-8662-3854ae0b3e94', 'CN01', 'empty', 'normal', 315, NULL, NULL, NULL, NULL, 2, NULL), ('f95ab7e4-ca69-40b3-99c8-f1f2bf7dcb97', 'CN01', 'empty', 'normal', 316, NULL, NULL, NULL, NULL, 2, NULL), ('e0278fa4-2033-4ffd-b760-18a4077dd88a', 'CN01', 'empty', 'normal', 317, NULL, NULL, NULL, NULL, 2, NULL), ('d32ffce7-e64d-4012-b826-775408179d51', 'CN01', 'empty', 'normal', 318, NULL, NULL, NULL, NULL, 2, NULL), ('3b480bb2-e072-4235-990f-82bf24465658', 'CN01', 'empty', 'normal', 319, NULL, NULL, NULL, NULL, 2, NULL), ('ba9fa558-8edf-4930-be3b-a04248dcfb75', 'CN01', 'empty', 'normal', 320, NULL, NULL, NULL, NULL, 2, NULL), ('2c3bc33a-6333-467e-bf22-7baf16ac166b', 'CN02', 'empty', 'normal', 101, NULL, NULL, NULL, NULL, 2, NULL), ('f5b9abcb-54c9-4c32-b396-ea4f6eefbcc5', 'CN02', 'empty', 'normal', 102, NULL, NULL, NULL, NULL, 2, NULL), ('def00d2e-bc04-404c-9dc5-7972fa52116c', 'CN02', 'empty', 'normal', 103, NULL, NULL, NULL, NULL, 2, NULL), ('4974ca03-9a6f-4ad7-b4c0-781bbfba0bac', 'CN02', 'empty', 'normal', 104, NULL, NULL, NULL, NULL, 2, NULL), ('d82c4483-f4f9-4d5a-a0b7-f338a542b65e', 'CN02', 'empty', 'normal', 105, NULL, NULL, NULL, NULL, 2, NULL), ('226c1468-4a3c-48cd-ad5d-ed79dbaa0ce6', 'CN02', 'empty', 'vip', 106, NULL, NULL, NULL, NULL, 2, NULL), ('6ae0ad85-7d23-4514-895e-c83c7963107a', 'CN02', 'empty', 'normal', 107, NULL, NULL, NULL, NULL, 2, NULL), ('c5ff94fc-998c-4855-acd3-ab844e6c69cd', 'CN02', 'empty', 'normal', 108, NULL, NULL, NULL, NULL, 2, NULL), ('fcdc926b-1e47-430c-838b-4feda05aeb09', 'CN02', 'empty', 'vip', 109, NULL, NULL, NULL, NULL, 2, NULL), ('3ab598d6-c400-48cf-ae8a-2d73c224720d', 'CN02', 'empty', 'normal', 110, NULL, NULL, NULL, NULL, 2, NULL), ('c316af3d-c57a-4718-9a09-f27a888b4540', 'CN02', 'empty', 'normal', 111, NULL, NULL, NULL, NULL, 2, NULL), ('e989bf52-5919-4262-b24d-8b269c8f6fce', 'CN02', 'empty', 'normal', 112, NULL, NULL, NULL, NULL, 2, NULL), ('f4e8114b-038f-4ef4-9cd4-0bc72fc4a61a', 'CN02', 'empty', 'normal', 113, NULL, NULL, NULL, NULL, 2, NULL), ('839f071b-1bc1-4e6d-8544-57ddf5e42ded', 'CN02', 'empty', 'vip', 114, NULL, NULL, NULL, NULL, 2, NULL), ('4073470e-9a1c-47b4-b58d-e7208c45b5fe', 'CN02', 'empty', 'normal', 115, NULL, NULL, NULL, NULL, 2, NULL), ('e618eb25-e1e0-44c7-881c-f2397f86ead4', 'CN02', 'empty', 'normal', 116, NULL, NULL, NULL, NULL, 2, NULL), ('73dbdb84-fac9-4898-8647-5698e9be565e', 'CN02', 'empty', 'normal', 117, NULL, NULL, NULL, NULL, 2, NULL), ('69ed59d1-d2e6-4ae4-837b-e5b0782fe847', 'CN02', 'empty', 'normal', 118, NULL, NULL, NULL, NULL, 2, NULL), ('812cf461-4041-43ed-be44-e984dd0e8141', 'CN02', 'empty', 'normal', 119, NULL, NULL, NULL, NULL, 2, NULL), ('2fe02cc4-443d-496e-a985-7b8bd0809fd9', 'CN02', 'empty', 'normal', 120, NULL, NULL, NULL, NULL, 2, NULL), ('9a4bf058-9a47-44cb-b8ea-716985480fcf', 'CN02', 'empty', 'normal', 201, NULL, NULL, NULL, NULL, 2, NULL), ('c935b05d-d435-4db0-a623-21a2898db652', 'CN02', 'empty', 'vip', 202, NULL, NULL, NULL, NULL, 2, NULL), ('00bbeed0-ef9b-468e-8c02-98b9e82ea6cd', 'CN02', 'empty', 'normal', 203, NULL, NULL, NULL, NULL, 2, NULL), ('897e3b5c-d9d5-4ec7-ae4f-02517ad86304', 'CN02', 'empty', 'normal', 204, NULL, NULL, NULL, NULL, 2, NULL), ('a0fc2c2d-93e2-438f-ab0e-3966ad8e26b3', 'CN02', 'empty', 'normal', 205, NULL, NULL, NULL, NULL, 2, NULL), ('3924a391-dee2-47f2-a163-8b1393b44501', 'CN02', 'empty', 'normal', 206, NULL, NULL, NULL, NULL, 2, NULL), ('03eac7c3-e8d6-471c-a48c-64132d963d6a', 'CN02', 'empty', 'vip', 207, NULL, NULL, NULL, NULL, 2, NULL), ('1cc3564e-d947-4325-bd62-5ae832e0a33d', 'CN02', 'empty', 'normal', 208, NULL, NULL, NULL, NULL, 2, NULL), ('97fd14dc-4fd6-40dc-aac4-30c9f00c7c86', 'CN02', 'empty', 'normal', 209, NULL, NULL, NULL, NULL, 2, NULL), ('1fcc8d69-3f0e-4f41-b2b5-b61b4929f14b', 'CN02', 'empty', 'normal', 210, NULL, NULL, NULL, NULL, 2, NULL), ('83e77a6d-84f8-42ed-bcb0-6a877197ea5f', 'CN02', 'empty', 'normal', 211, NULL, NULL, NULL, NULL, 2, NULL), ('9c8a49f0-fd01-4b5b-a54b-d60dadf99bcd', 'CN02', 'empty', 'normal', 212, NULL, NULL, NULL, NULL, 2, NULL), ('b8eb833b-760f-44da-b248-8b2206306d6b', 'CN02', 'empty', 'normal', 213, NULL, NULL, NULL, NULL, 2, NULL), ('4fabbaa7-c227-474b-919a-ee30bd8d715e', 'CN02', 'empty', 'normal', 214, NULL, NULL, NULL, NULL, 2, NULL), ('ef4c70ea-dd6e-4f72-813e-671994226012', 'CN02', 'empty', 'vip', 215, NULL, NULL, NULL, NULL, 2, NULL), ('8185a97f-abb0-4d33-a940-a11c66cec863', 'CN02', 'empty', 'normal', 216, NULL, NULL, NULL, NULL, 2, NULL), ('f28e807c-529f-4232-bdf8-0bc78e1cebbf', 'CN02', 'empty', 'normal', 217, NULL, NULL, NULL, NULL, 2, NULL), ('4919222d-e1cc-4c86-b4ee-7fec73178816', 'CN02', 'empty', 'normal', 218, NULL, NULL, NULL, NULL, 2, NULL), ('d6d44711-e239-4eaf-a83c-b94f7e56002c', 'CN02', 'empty', 'vip', 219, NULL, NULL, NULL, NULL, 2, NULL), ('201c9f83-37c0-4bae-8b2a-f2e6de5d956f', 'CN02', 'empty', 'normal', 220, NULL, NULL, NULL, NULL, 2, NULL), ('8035da3c-aae2-42a1-8e4e-6cf10e25cad5', 'CN02', 'empty', 'normal', 301, NULL, NULL, NULL, NULL, 2, NULL), ('c916e636-caca-4cbe-bd09-3a0859653c79', 'CN02', 'empty', 'normal', 302, NULL, NULL, NULL, NULL, 2, NULL), ('e1a88a3e-f67e-4440-896d-55506a5b37bd', 'CN02', 'empty', 'normal', 303, NULL, NULL, NULL, NULL, 2, NULL), ('62c2432d-e057-40a7-8c6c-729698f94768', 'CN02', 'empty', 'normal', 304, NULL, NULL, NULL, NULL, 2, NULL), ('da21bd74-a16f-4edb-a78e-f94a7990800f', 'CN02', 'empty', 'normal', 305, NULL, NULL, NULL, NULL, 2, NULL), ('9d984a4c-e6b7-4ad1-a2a9-fefc080e6b1c', 'CN02', 'empty', 'normal', 306, NULL, NULL, NULL, NULL, 2, NULL), ('51723e0e-90da-49e0-b2a1-18fcdd08fae0', 'CN02', 'empty', 'normal', 307, NULL, NULL, NULL, NULL, 2, NULL), ('4a453f7d-ca02-4499-a96b-dbfcb11a97c0', 'CN02', 'empty', 'normal', 308, NULL, NULL, NULL, NULL, 2, NULL), ('29c8b40f-14d8-4c46-9262-b888b2792aec', 'CN02', 'empty', 'normal', 309, NULL, NULL, NULL, NULL, 2, NULL), ('7a85b64a-fd0b-41d4-900a-26892f03574b', 'CN02', 'empty', 'normal', 310, NULL, NULL, NULL, NULL, 2, NULL), ('cd003266-7ba4-415d-bbb7-e05baf443dd8', 'CN02', 'empty', 'normal', 311, NULL, NULL, NULL, NULL, 2, NULL), ('f520eb22-8273-4cdf-b0db-3baab2eda655', 'CN02', 'empty', 'normal', 312, NULL, NULL, NULL, NULL, 2, NULL), ('1daf96af-c734-433e-8c09-1e8363488ca2', 'CN02', 'empty', 'normal', 313, NULL, NULL, NULL, NULL, 2, NULL), ('ed0f6602-3b8f-4cf4-a60d-fc7a37468254', 'CN02', 'empty', 'normal', 314, NULL, NULL, NULL, NULL, 2, NULL), ('ff16eebe-19dc-4668-87bd-a352ecda8ace', 'CN02', 'empty', 'normal', 315, NULL, NULL, NULL, NULL, 2, NULL), ('1e5667dc-cf8d-49ae-b8b6-565b28298aff', 'CN02', 'empty', 'normal', 316, NULL, NULL, NULL, NULL, 2, NULL), ('7879033f-e0ac-4df6-bf9a-586b084f795e', 'CN02', 'empty', 'normal', 317, NULL, NULL, NULL, NULL, 2, NULL), ('1a239e12-d03c-4524-82ab-1094aa479930', 'CN02', 'empty', 'normal', 318, NULL, NULL, NULL, NULL, 2, NULL), ('9e880e44-b57b-41bc-8c85-0254c5c6688e', 'CN02', 'empty', 'normal', 319, NULL, NULL, NULL, NULL, 2, NULL), ('299720d2-1fc1-49f1-ae1c-398f0aad52c3', 'CN02', 'empty', 'normal', 320, NULL, NULL, NULL, NULL, 2, NULL);


INSERT INTO CoSoVatChatPhong (ID, TenTrangBi, GiaMua, MaSanPham, TinhTrang, MaPhong, imageURL) VALUES ('bc42741a-d4fa-437b-b7d8-b54cafdcea3e', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '1ef2149f-2f72-4e3c-9c35-3a049e62d8ff', NULL), ('3b7e1fd1-7ca2-4087-aac2-bc71e12bad49', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '8cb5652e-3613-41a7-9f33-0549dcb1adce', NULL), ('2b3a734c-fce2-4b3e-8e06-b8e67894ce03', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'e9fd906e-5655-4cf6-8d4f-7d4556243114', NULL), ('a950ce14-882a-4c3b-9543-c89b2944abd5', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '8627801c-f14d-4a86-844e-73163eac571a', NULL), ('0241a274-1043-48ab-8efa-8a7ed067558d', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'a250f35d-5818-40bd-9def-9056a4f7f3ce', NULL), ('4105f4a2-19f1-4f62-a807-d0d0e0431bd8', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'a868b143-d2a3-48c8-a9e0-1ddd17f89441', NULL), ('6e180665-49ac-4a80-9968-1548eb61b59e', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '9987b36d-7dce-4d3b-971c-f951096545d4', NULL), ('81071aae-856a-402f-bc3d-9fda280a9885', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '08c9f188-457a-451d-91cc-81f51af8b92f', NULL), ('18df7bdb-5dd1-4ebd-9aa5-21a3d9387178', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'f0c77063-f713-4b0f-94ad-4327b41a54b7', NULL), ('74f684e9-0605-4e71-a874-59499db8b9fc', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '73e69a97-3b87-4f19-9286-5013037cf94d', NULL), ('2e85fbfd-848b-4d6d-8a63-dfa599c54735', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '9eb60dc2-fccb-4c23-803a-a3914e359f13', NULL), ('b99e39bb-9e3d-43dc-93d6-5f0d68fdde10', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '1df5902e-2795-4c0e-a6c1-45d69abf7d5c', NULL), ('3832ea83-a662-4fa7-b2a5-d2f9cfd3cc7b', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '26281e30-03c0-44cf-9dc7-fc3b772b82a7', NULL), ('b95dad8f-16fd-4d27-b8b8-4ba673177156', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'fe6f4efe-6553-4d8c-b895-80fa27246d20', NULL), ('b4fab44f-2f05-426a-962b-4a4c9f95e531', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '987c8df6-4171-410b-97da-34c8de21dffa', NULL), ('29481c37-2879-48c0-8ad8-5db64ef39f5a', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '632b2417-2af6-40a0-ab65-25d21e2d3861', NULL), ('4f9fc521-3fe1-4596-85d1-df05b0e5b2b0', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'd61af8de-2636-48bf-bfb2-a7ba4c331dff', NULL), ('e8fdb410-a52f-4170-bb4c-9500e10e6485', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'a958254a-24e9-4fff-bfe6-7040b569b9d0', NULL), ('22162abf-8e5c-4f8d-875b-adb927d1bebe', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'e57a204f-23d1-460c-ac07-69281e82b2f4', NULL), ('530f3661-cb26-4abe-8160-b19892a96874', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '48c6ef9e-37eb-4ba2-9c2d-f78bd3a2ead6', NULL), ('a31a64e7-5a6a-4a9a-a72e-51cf2d572dfd', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '019f2ab2-b53b-4d53-b772-0f7e1d48c4a6', NULL), ('e1bef55c-6e2d-4d3a-82f1-33173618bdc4', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '25c3f188-c0a5-4204-b19b-0122f7934346', NULL), ('56eb8be9-55a5-4d97-a407-0c87ef2ad064', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '8a45b9a2-a878-45d5-b44c-1d0ba1198cdc', NULL), ('54fd7220-d5cd-433d-a65c-857eaa07c54d', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '7be0476c-eb64-44f3-83af-c2ca66fedce9', NULL), ('8d333601-a8b8-44f1-a899-d159ed51c99d', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'e5b1450f-b40e-4eed-a4d4-5523aa4b5f3b', NULL), ('593e59f2-f004-49ba-874e-ceb598bc3523', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '8f21ec70-3804-4b6e-82c4-c281c63bd367', NULL), ('7ac41e98-b96f-404e-b1a9-2fb532fa02bc', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '7ca6f209-fce2-4964-be46-c6c75829ba3f', NULL), ('d1f2ec59-07ff-4263-a7c9-9c9ede111599', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'b288415f-d11e-45a8-bd66-cf04fd98cf80', NULL), ('33363211-f026-4fa9-a2d8-2a32e0532e76', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '3e091c8c-945a-4d6f-bc8d-f99b55aad2c2', NULL), ('410e549e-cef5-4e08-92a5-c1d29faf4b00', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '339f11ff-91e1-4a8d-b1c2-f56b8a50fc74', NULL), ('398b695a-f7dc-468f-a52a-8c4a883dc79b', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'ed817e6f-1358-4167-9db7-8cf2531f3e53', NULL), ('b072510c-c3c0-4fb3-a9c1-76890ae6657e', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '54c627b4-887b-4c17-a7d8-7afcd43b7db2', NULL), ('8e9069c5-0656-4e4e-a633-457a5722bc9b', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '4ab7809f-e764-4df8-948c-b1e4164a1245', NULL), ('93be9099-1c30-4175-97ed-d0676c81f8e4', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '982beab5-2431-4f54-b826-5ac794449cd2', NULL), ('d40945a6-98cb-4052-8f54-f9006306197f', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '0a6e8fbf-00de-4756-bc05-a44fe89e09a8', NULL), ('02522c0c-5926-4c15-b261-eb2db31b8d0e', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '0ef0294d-af49-46fd-a2aa-46d2c919ab4b', NULL), ('a3026390-3cc8-4d53-a519-e7cff881a268', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '6dc76e97-f347-4f1b-a391-da38ad26ca92', NULL), ('e46ac9fd-ba25-4d7d-be7c-6eb731f7c969', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '19a6bbe3-553a-4f25-82dd-2871213f9c8b', NULL), ('d994f317-011f-4208-975b-c39bf63f3de1', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'a6024b97-08e1-4631-9a17-7db7dbb76761', NULL), ('1e94a8f8-8e5b-4d67-897b-b8a2a4e1f1fd', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '6c2fc256-2bd0-4c6d-a4fa-68d386e11523', NULL), ('e6f09efd-cefb-44cd-ba78-4ad05f47a39d', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '5b603c38-1b6f-4f95-a796-4ced6600fdf8', NULL), ('adbaf2ed-956d-4a01-b297-def97929c96e', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '3a3b6b6f-396c-447d-bb9f-77bf1bd56266', NULL), ('262322d7-5a14-4eba-a930-c78fbdbd8667', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'a3e3792b-7439-4237-a903-ffe8dd24b5eb', NULL), ('61a780c5-556d-4fbb-b967-5510d5b7aeab', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'c0e09f3d-a6cd-4305-8a9d-6b40434c8c51', NULL), ('b6bfa9dc-5127-44ea-9b51-ba5f8dc7435a', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '8dd30ed1-22ff-45ab-8067-b65f9d8d4ff8', NULL), ('adfdca6d-3942-4ec6-8b91-5c6af499e5e3', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '51d291d5-844a-4f12-b9d8-98d72ca468d3', NULL), ('83a02caa-695b-4e6a-8ea3-8338a2879b71', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '9d37e0f6-3981-4fe6-82f7-204e739c762e', NULL), ('f2325277-5c40-4d59-9d99-39205b11f4af', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '65ab4f2d-251d-4bcf-8d10-13b215a82cb2', NULL), ('7f3f73d9-789c-4674-9137-4e10f367f07c', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '2e31cb4b-11d8-4c24-8be3-c2ebf47ea6fe', NULL), ('e3051c06-7e7a-4a1d-8fb7-33e28bd6ea43', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '420c9af0-63f1-4e8d-a619-e39425bd621f', NULL), ('248a7be9-cd14-47c3-a4f7-6b48a297370c', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'adaab164-cb3e-4c38-8665-4f87557fc73f', NULL), ('f8d8693f-5d77-4cb2-aae8-cbfad5a3f03f', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '68834c21-9d0a-4ac0-803a-c07d1a57cc85', NULL), ('40407ee3-6f23-413b-bf19-5d6b8b9e3436', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '6ccd9968-eb06-4647-942c-82ca7590b756', NULL), ('8a7ffbb1-b17a-48bd-887c-5f512c1daa59', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '57280b0e-6dab-4592-8288-ff684955d6bc', NULL), ('6fc44989-eee6-4f1f-b87d-4ad1d3203b55', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '54804511-0e29-424d-8662-3854ae0b3e94', NULL), ('56252fcc-0fe1-41b2-b088-71b3b4e8aeed', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'f95ab7e4-ca69-40b3-99c8-f1f2bf7dcb97', NULL), ('0202c005-69c7-4044-ab40-f4e0e492fd34', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'e0278fa4-2033-4ffd-b760-18a4077dd88a', NULL), ('5094dd73-d9da-4451-8d46-0ed633eed929', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'd32ffce7-e64d-4012-b826-775408179d51', NULL), ('63e4c76c-644d-4160-bbf4-65abaf43d24e', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '3b480bb2-e072-4235-990f-82bf24465658', NULL), ('283f4ad5-081b-48d4-894d-a6c97790d446', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'ba9fa558-8edf-4930-be3b-a04248dcfb75', NULL), ('d0098470-d0c9-4c8a-982d-48f204305835', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '2c3bc33a-6333-467e-bf22-7baf16ac166b', NULL), ('6eed1fa0-5813-44c7-a547-37961a64b5f3', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'f5b9abcb-54c9-4c32-b396-ea4f6eefbcc5', NULL), ('b91660e6-5434-4283-b467-f6449b230cf5', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'def00d2e-bc04-404c-9dc5-7972fa52116c', NULL), ('d1ad29b0-bbf5-4f56-828a-9bc265559dd4', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '4974ca03-9a6f-4ad7-b4c0-781bbfba0bac', NULL), ('291c6daa-316e-494f-a4dc-9a00cc560bfa', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'd82c4483-f4f9-4d5a-a0b7-f338a542b65e', NULL), ('3aadf82c-1afc-40f5-8eb1-6918642d1206', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '226c1468-4a3c-48cd-ad5d-ed79dbaa0ce6', NULL), ('fb93712a-1247-4a22-80ef-1b2f01a443a6', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '6ae0ad85-7d23-4514-895e-c83c7963107a', NULL), ('bd30f904-f605-4d15-b5e3-342ee2bbfec6', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'c5ff94fc-998c-4855-acd3-ab844e6c69cd', NULL), ('245a4260-1c80-40b0-aaed-8d2718d96f54', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'fcdc926b-1e47-430c-838b-4feda05aeb09', NULL), ('3d4a2196-ce62-4d98-b128-9d5312ed9d6a', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '3ab598d6-c400-48cf-ae8a-2d73c224720d', NULL), ('c7dfcd44-193e-46cd-9ee2-229ac31eefa4', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'c316af3d-c57a-4718-9a09-f27a888b4540', NULL), ('257ded1b-a0c3-4cbc-bde9-f677e0558bb9', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'e989bf52-5919-4262-b24d-8b269c8f6fce', NULL), ('f138c66a-1fd8-4855-89b3-011ae2caea60', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'f4e8114b-038f-4ef4-9cd4-0bc72fc4a61a', NULL), ('27199007-b8a1-4063-b8c1-911d09041a1a', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '839f071b-1bc1-4e6d-8544-57ddf5e42ded', NULL), ('4da44bec-d959-4f1f-a930-d8ad78126b98', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '4073470e-9a1c-47b4-b58d-e7208c45b5fe', NULL), ('107bc563-8b33-429e-914e-da507eb5e3e2', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'e618eb25-e1e0-44c7-881c-f2397f86ead4', NULL), ('a167a348-1bf7-4224-845d-3b1e18612404', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '73dbdb84-fac9-4898-8647-5698e9be565e', NULL), ('5cc29904-29be-4706-82fe-822fbd6810dd', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '69ed59d1-d2e6-4ae4-837b-e5b0782fe847', NULL), ('64c5d955-8c2e-4a34-ad25-da92ddf01818', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '812cf461-4041-43ed-be44-e984dd0e8141', NULL), ('b3c6b10b-6a82-47ae-86ed-b46b2127c3bc', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '2fe02cc4-443d-496e-a985-7b8bd0809fd9', NULL), ('aff21c51-71ee-489b-9b5c-bccf25bccf04', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '9a4bf058-9a47-44cb-b8ea-716985480fcf', NULL), ('670659c5-cf12-4123-a870-2c9c1fc9cdca', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'c935b05d-d435-4db0-a623-21a2898db652', NULL), ('7050fad4-e174-428b-aafe-1918e124fc15', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '00bbeed0-ef9b-468e-8c02-98b9e82ea6cd', NULL), ('9c65e23d-f3f3-4d03-a7f8-c7f8b49a21d3', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '897e3b5c-d9d5-4ec7-ae4f-02517ad86304', NULL), ('8e199a2f-91a6-46fd-a7bd-9459ea3cc68e', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'a0fc2c2d-93e2-438f-ab0e-3966ad8e26b3', NULL), ('24d957f7-b06a-4688-be51-1cebed2db9f1', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '3924a391-dee2-47f2-a163-8b1393b44501', NULL), ('4c41f78c-0673-4c12-8a8a-38368cef1a6d', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '03eac7c3-e8d6-471c-a48c-64132d963d6a', NULL), ('91d40c0d-64a2-4184-b0bc-1ecad4c94fd3', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '1cc3564e-d947-4325-bd62-5ae832e0a33d', NULL), ('410681c9-96da-46d9-b98f-4bfda3b76f9b', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '97fd14dc-4fd6-40dc-aac4-30c9f00c7c86', NULL), ('2e518eb1-b8d5-41d1-8907-a95eb6667c56', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '1fcc8d69-3f0e-4f41-b2b5-b61b4929f14b', NULL), ('cfb0e9a3-764a-4b34-97c3-04da33c2bdbb', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '83e77a6d-84f8-42ed-bcb0-6a877197ea5f', NULL), ('0e522231-0bc6-4273-84f9-c473b6c6e094', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '9c8a49f0-fd01-4b5b-a54b-d60dadf99bcd', NULL), ('c79169d7-3f5e-4ca8-8777-c5d1017c9cb8', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'b8eb833b-760f-44da-b248-8b2206306d6b', NULL), ('dd00d8da-5968-4cab-afc6-ef77b3f14df1', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '4fabbaa7-c227-474b-919a-ee30bd8d715e', NULL), ('5cc2745a-3adc-4f6d-b2f8-8ed7996ac9f7', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'ef4c70ea-dd6e-4f72-813e-671994226012', NULL), ('ade894e4-8256-4121-b235-c4052dbd9c83', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '8185a97f-abb0-4d33-a940-a11c66cec863', NULL), ('06fcd8c1-dcbb-4c60-8f92-fe6d43790037', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'f28e807c-529f-4232-bdf8-0bc78e1cebbf', NULL), ('99ff98a2-4368-4e6f-9353-7bb3f84c287f', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '4919222d-e1cc-4c86-b4ee-7fec73178816', NULL), ('0ecba9c6-b625-4316-92cd-98e5d9118ba6', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'd6d44711-e239-4eaf-a83c-b94f7e56002c', NULL), ('c57d782b-d0f0-4ddb-84f7-88b29f0a22eb', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '201c9f83-37c0-4bae-8b2a-f2e6de5d956f', NULL), ('f38a4a0e-d8c0-4f1b-bcb4-921fd4f9c5b4', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '8035da3c-aae2-42a1-8e4e-6cf10e25cad5', NULL), ('c84ccfe9-8274-4d8b-8880-9da577e57b6c', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'c916e636-caca-4cbe-bd09-3a0859653c79', NULL), ('bf2f453c-9345-455c-a119-343961f07568', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'e1a88a3e-f67e-4440-896d-55506a5b37bd', NULL), ('672b86d8-c720-4d36-95b8-28c25e5b2d8d', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '62c2432d-e057-40a7-8c6c-729698f94768', NULL), ('4e9f3ac6-dc2b-4bb3-beed-c643782ec9c5', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'da21bd74-a16f-4edb-a78e-f94a7990800f', NULL), ('160be23d-0720-4a7e-9549-e94c0bb6d0a7', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '9d984a4c-e6b7-4ad1-a2a9-fefc080e6b1c', NULL), ('da729873-f5a1-4f60-acfc-ef0768ed6318', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '51723e0e-90da-49e0-b2a1-18fcdd08fae0', NULL), ('7ebd4cd4-a40b-4714-a293-ae1651c14dc5', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '4a453f7d-ca02-4499-a96b-dbfcb11a97c0', NULL), ('b656ad37-7de0-4e06-830a-b4766914ac10', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '29c8b40f-14d8-4c46-9262-b888b2792aec', NULL), ('3da9c9a7-5126-4984-9773-3c0579d55528', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '7a85b64a-fd0b-41d4-900a-26892f03574b', NULL), ('107affbd-8b2f-495f-a38c-d6deec6e6e72', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'cd003266-7ba4-415d-bbb7-e05baf443dd8', NULL), ('ed227556-aa42-40ad-af60-0bb2cb402e63', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'f520eb22-8273-4cdf-b0db-3baab2eda655', NULL), ('069bd718-1afa-4f64-a6dd-ba15309c9480', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '1daf96af-c734-433e-8c09-1e8363488ca2', NULL), ('c2321630-186c-468c-bd4d-dbca89082510', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'ed0f6602-3b8f-4cf4-a60d-fc7a37468254', NULL), ('40af727e-a225-4422-a193-d495cfc3576c', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', 'ff16eebe-19dc-4668-87bd-a352ecda8ace', NULL), ('3a490ae8-8369-4a4e-a002-9e9aead78aa0', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '1e5667dc-cf8d-49ae-b8b6-565b28298aff', NULL), ('9dbb5196-57f3-42cf-8520-ed3263d1d6de', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '7879033f-e0ac-4df6-bf9a-586b084f795e', NULL), ('819b6d83-6f7a-4e83-9306-0f8d97b3cb26', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '1a239e12-d03c-4524-82ab-1094aa479930', NULL), ('c8f5fddb-7472-4aec-99be-ffc8eb403690', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '9e880e44-b57b-41bc-8c85-0254c5c6688e', NULL), ('dd8e0321-e0e8-45f0-a00e-0c9fa49fda01', 'Máy lạnh', '12000000', 'RAS-H13Z1KCVG-V', 'good', '299720d2-1fc1-49f1-ae1c-398f0aad52c3', NULL), ('e6fd65a6-3c04-4c1e-8c06-9ca8833e4910', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '1ef2149f-2f72-4e3c-9c35-3a049e62d8ff', NULL), ('58f9a0d9-6daa-41db-9dec-1851a717b1c1', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '8cb5652e-3613-41a7-9f33-0549dcb1adce', NULL), ('16ac4324-c8de-46a0-8985-5d7c0d4a23ba', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'e9fd906e-5655-4cf6-8d4f-7d4556243114', NULL), ('c5cf16c5-c807-4033-94cc-5139e8f96914', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '8627801c-f14d-4a86-844e-73163eac571a', NULL), ('9a3c3783-71b5-4fc2-b1fb-aeab21409598', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'a250f35d-5818-40bd-9def-9056a4f7f3ce', NULL), ('006d6edd-be62-488d-b294-1db4434443ba', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'a868b143-d2a3-48c8-a9e0-1ddd17f89441', NULL), ('7c1a7718-c17e-43f1-8b3e-b97c0c93bc77', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '9987b36d-7dce-4d3b-971c-f951096545d4', NULL), ('3bacac63-f7b4-4a84-bd8d-150dfab1dd2e', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '08c9f188-457a-451d-91cc-81f51af8b92f', NULL), ('00c0afd4-7174-4781-baea-c60931608744', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'f0c77063-f713-4b0f-94ad-4327b41a54b7', NULL), ('e789f775-73ee-41cd-a52b-00713f8413d9', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '73e69a97-3b87-4f19-9286-5013037cf94d', NULL), ('d8ae04d5-2bd9-46cd-a785-cb23ddbe020f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '9eb60dc2-fccb-4c23-803a-a3914e359f13', NULL), ('496be6b2-e8a0-405e-9cd9-86ec313f298f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '1df5902e-2795-4c0e-a6c1-45d69abf7d5c', NULL), ('31811f19-c28e-4e8e-ad09-066908a10571', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '26281e30-03c0-44cf-9dc7-fc3b772b82a7', NULL), ('b1160d30-f428-43ae-badc-38b2348ebfcd', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'fe6f4efe-6553-4d8c-b895-80fa27246d20', NULL), ('6b528791-562c-41fd-99f9-49f9cad78b32', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '987c8df6-4171-410b-97da-34c8de21dffa', NULL), ('4644c4ce-420c-475a-a887-7dbffd62f26b', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '632b2417-2af6-40a0-ab65-25d21e2d3861', NULL), ('5241c723-c620-4ca3-a379-2bec5a908eda', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'd61af8de-2636-48bf-bfb2-a7ba4c331dff', NULL), ('7f3f5d29-24fb-4bec-853d-2df13ca77bcd', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'a958254a-24e9-4fff-bfe6-7040b569b9d0', NULL), ('08f77bc4-845b-49d7-b294-d86d40b99ff1', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'e57a204f-23d1-460c-ac07-69281e82b2f4', NULL), ('f85af936-87b4-49f1-b717-37a4e84e0e1d', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '48c6ef9e-37eb-4ba2-9c2d-f78bd3a2ead6', NULL), ('1ac38779-1851-4d78-b045-77308334d96f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '019f2ab2-b53b-4d53-b772-0f7e1d48c4a6', NULL), ('1478ef4e-e51d-4802-849d-5bcf240277af', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '25c3f188-c0a5-4204-b19b-0122f7934346', NULL), ('4d25e81f-785e-4c09-8da4-29069e4ed3b8', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '8a45b9a2-a878-45d5-b44c-1d0ba1198cdc', NULL), ('5f8c1948-8fae-47cc-9771-fd198532ce96', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '7be0476c-eb64-44f3-83af-c2ca66fedce9', NULL), ('4f842bf7-d50c-4f63-9ee2-3832a534d213', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'e5b1450f-b40e-4eed-a4d4-5523aa4b5f3b', NULL), ('9505d628-8437-403a-8c6a-ed09bc1ed309', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '8f21ec70-3804-4b6e-82c4-c281c63bd367', NULL), ('98f3365c-5a44-47db-b3a0-ba008462303a', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '7ca6f209-fce2-4964-be46-c6c75829ba3f', NULL), ('0d166d2f-1d33-4c5d-82dc-74e749f3e312', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'b288415f-d11e-45a8-bd66-cf04fd98cf80', NULL), ('e261156c-3d9f-4f4b-8a54-90be224ca26f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '3e091c8c-945a-4d6f-bc8d-f99b55aad2c2', NULL), ('133a404f-5058-4aca-be3c-7e6b82568426', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '339f11ff-91e1-4a8d-b1c2-f56b8a50fc74', NULL), ('33598cd2-274c-44b5-aec7-ebdab2b4ea91', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'ed817e6f-1358-4167-9db7-8cf2531f3e53', NULL), ('dcc72a2c-f30b-4800-b134-246285b95f7a', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '54c627b4-887b-4c17-a7d8-7afcd43b7db2', NULL), ('a68b5ca4-960b-4230-b1b7-343ac76e4346', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '4ab7809f-e764-4df8-948c-b1e4164a1245', NULL), ('58d73082-4dcc-4127-9c77-c2aa0e79ea65', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '982beab5-2431-4f54-b826-5ac794449cd2', NULL), ('05f55b8e-ac04-4a4b-9d20-c548b496c15c', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '0a6e8fbf-00de-4756-bc05-a44fe89e09a8', NULL), ('74ba85b7-8e1b-4d3b-b145-80ceff3428f6', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '0ef0294d-af49-46fd-a2aa-46d2c919ab4b', NULL), ('d942c410-1a71-46fa-9bee-1ddd3600babd', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '6dc76e97-f347-4f1b-a391-da38ad26ca92', NULL), ('65ded7c7-9702-4244-800b-ab655cd94b7d', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '19a6bbe3-553a-4f25-82dd-2871213f9c8b', NULL), ('d083a1cb-35a1-498a-a200-facabb634fec', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'a6024b97-08e1-4631-9a17-7db7dbb76761', NULL), ('b448cb76-d6b1-4fb2-94ce-6fa509d7d890', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '6c2fc256-2bd0-4c6d-a4fa-68d386e11523', NULL), ('0a9bb7be-8b19-44d5-a452-37c47a298acd', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '5b603c38-1b6f-4f95-a796-4ced6600fdf8', NULL), ('dcdaafcd-4fe9-44ea-98f2-88298721328e', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '3a3b6b6f-396c-447d-bb9f-77bf1bd56266', NULL), ('4fd29b8a-a3dd-4cc8-9954-2b447266c16c', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'a3e3792b-7439-4237-a903-ffe8dd24b5eb', NULL), ('601e4f84-dab2-4d60-822e-c57589699304', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'c0e09f3d-a6cd-4305-8a9d-6b40434c8c51', NULL), ('e7e8c305-ab35-4e3b-8bea-c4777237257f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '8dd30ed1-22ff-45ab-8067-b65f9d8d4ff8', NULL), ('126ca642-dc10-448f-9617-beed008cd30b', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '51d291d5-844a-4f12-b9d8-98d72ca468d3', NULL), ('59bf45a7-02eb-4237-a1f3-09cff38f001a', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '9d37e0f6-3981-4fe6-82f7-204e739c762e', NULL), ('ed8372c2-986b-4876-91b9-406ca5b756b1', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '65ab4f2d-251d-4bcf-8d10-13b215a82cb2', NULL), ('9ff1226d-eef1-4641-9b9a-42e77de563ea', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '2e31cb4b-11d8-4c24-8be3-c2ebf47ea6fe', NULL), ('574c52ca-5874-4d3c-bf70-b7363d4ff99f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '420c9af0-63f1-4e8d-a619-e39425bd621f', NULL), ('47d5dc47-1f7c-4989-be52-a4ab96a044ee', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'adaab164-cb3e-4c38-8665-4f87557fc73f', NULL), ('1c125a22-fa4a-409f-8af5-53c744344007', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '68834c21-9d0a-4ac0-803a-c07d1a57cc85', NULL), ('1cbd6779-8d24-406f-8507-107a607fd232', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '6ccd9968-eb06-4647-942c-82ca7590b756', NULL), ('dc853f5b-8271-462f-b704-b217e3425e85', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '57280b0e-6dab-4592-8288-ff684955d6bc', NULL), ('7598e8ce-a40e-461a-98ae-6305b4b5cab7', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '54804511-0e29-424d-8662-3854ae0b3e94', NULL), ('81b8dd13-8ce3-4680-9d27-752b1eec64f2', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'f95ab7e4-ca69-40b3-99c8-f1f2bf7dcb97', NULL), ('7dfa53e0-9468-49eb-8732-0465681c7267', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'e0278fa4-2033-4ffd-b760-18a4077dd88a', NULL), ('8949403e-2daa-452d-974b-5172ac3f3a38', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'd32ffce7-e64d-4012-b826-775408179d51', NULL), ('54b848d3-ea2c-486b-a99c-de28e4d561cb', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '3b480bb2-e072-4235-990f-82bf24465658', NULL), ('76ac66ae-e8ce-43cd-a03b-2c02390b9d30', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'ba9fa558-8edf-4930-be3b-a04248dcfb75', NULL), ('301602e3-9d81-4f8d-8961-97e769be0361', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '2c3bc33a-6333-467e-bf22-7baf16ac166b', NULL), ('303a618a-05e6-4d56-a9fb-9465c6680486', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'f5b9abcb-54c9-4c32-b396-ea4f6eefbcc5', NULL), ('349141e4-de08-4e5a-a4f0-7ecda613b95a', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'def00d2e-bc04-404c-9dc5-7972fa52116c', NULL), ('8b8c89d9-cbf9-4991-9313-d5811df96f5a', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '4974ca03-9a6f-4ad7-b4c0-781bbfba0bac', NULL), ('eba17fbc-5b5f-4343-b0c2-d9cce61414a4', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'd82c4483-f4f9-4d5a-a0b7-f338a542b65e', NULL), ('60718282-13a5-4143-8559-63dca0cd8b2a', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '226c1468-4a3c-48cd-ad5d-ed79dbaa0ce6', NULL), ('262b9d96-f5b3-4d94-8102-90b03ca68626', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '6ae0ad85-7d23-4514-895e-c83c7963107a', NULL), ('cb662f3d-588d-4c1d-8a7c-91dd953c7370', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'c5ff94fc-998c-4855-acd3-ab844e6c69cd', NULL), ('0b531d20-d108-418a-bab8-e3740094f533', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'fcdc926b-1e47-430c-838b-4feda05aeb09', NULL), ('bb1c9b3a-aaea-4c3e-847f-2917863e1838', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '3ab598d6-c400-48cf-ae8a-2d73c224720d', NULL), ('58aab673-cef5-48f4-a142-2b72bda23fa8', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'c316af3d-c57a-4718-9a09-f27a888b4540', NULL), ('2b80c4b3-5a2f-4e2f-84e2-d75fcd717df4', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'e989bf52-5919-4262-b24d-8b269c8f6fce', NULL), ('66ebea8f-9c36-46fa-a821-a03c5d4c9f13', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'f4e8114b-038f-4ef4-9cd4-0bc72fc4a61a', NULL), ('306f9ed1-82fc-4b52-8f90-a5fe88d72e87', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '839f071b-1bc1-4e6d-8544-57ddf5e42ded', NULL), ('74b9a429-2d31-4086-9250-255d476abf4c', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '4073470e-9a1c-47b4-b58d-e7208c45b5fe', NULL), ('6a119259-f035-454d-89aa-19317b580c3e', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'e618eb25-e1e0-44c7-881c-f2397f86ead4', NULL), ('e5a629b2-cea7-4f36-a715-467f7b7c8ca3', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '73dbdb84-fac9-4898-8647-5698e9be565e', NULL), ('8978ffc7-d45b-4b86-87ff-94b579fd4f0d', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '69ed59d1-d2e6-4ae4-837b-e5b0782fe847', NULL), ('808c2f82-d809-4cf5-8a97-5ee1edec6530', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '812cf461-4041-43ed-be44-e984dd0e8141', NULL), ('01aa7a6b-50ca-454b-95a3-b47d161c35c5', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '2fe02cc4-443d-496e-a985-7b8bd0809fd9', NULL), ('408159bb-1100-44ce-8af6-2798cb3441dd', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '9a4bf058-9a47-44cb-b8ea-716985480fcf', NULL), ('b5e86538-d988-4f46-9cc9-b1077ce72ecb', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'c935b05d-d435-4db0-a623-21a2898db652', NULL), ('3da3af66-612d-46fb-8724-17390a5b7b5d', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '00bbeed0-ef9b-468e-8c02-98b9e82ea6cd', NULL), ('5dddb03e-3417-422f-83d2-9f23e2283f01', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '897e3b5c-d9d5-4ec7-ae4f-02517ad86304', NULL), ('c2d4ccab-5527-46a9-8f3e-688981b2f1ff', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'a0fc2c2d-93e2-438f-ab0e-3966ad8e26b3', NULL), ('89f28ce1-1924-4208-ac42-cf66ca56d4df', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '3924a391-dee2-47f2-a163-8b1393b44501', NULL), ('1acb74d3-8fe0-4544-b5a9-1b6fe305d932', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '03eac7c3-e8d6-471c-a48c-64132d963d6a', NULL), ('811a2365-5562-4f4e-96d4-0d7aed056b55', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '1cc3564e-d947-4325-bd62-5ae832e0a33d', NULL), ('12f61310-5f91-485e-a438-e56ade2cc25a', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '97fd14dc-4fd6-40dc-aac4-30c9f00c7c86', NULL), ('bedc30c2-8590-4f28-a099-358a551d914d', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '1fcc8d69-3f0e-4f41-b2b5-b61b4929f14b', NULL), ('88b6b16b-b441-481a-9ee9-97acb79ff3b8', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '83e77a6d-84f8-42ed-bcb0-6a877197ea5f', NULL), ('4e8372d5-a21c-4a09-a1b2-c99f839a79b2', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '9c8a49f0-fd01-4b5b-a54b-d60dadf99bcd', NULL), ('c45f33d6-7dc0-49d8-9af4-49e3ecab5374', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'b8eb833b-760f-44da-b248-8b2206306d6b', NULL), ('eac20f51-7c6c-471a-b120-4958e3d78a71', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '4fabbaa7-c227-474b-919a-ee30bd8d715e', NULL), ('d3c3447c-f872-47c2-a481-81c67651c378', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'ef4c70ea-dd6e-4f72-813e-671994226012', NULL), ('e9828d6d-5906-442d-92bd-92be7170557c', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '8185a97f-abb0-4d33-a940-a11c66cec863', NULL), ('290f7a0f-0b23-4c39-abf9-459d27cf7949', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'f28e807c-529f-4232-bdf8-0bc78e1cebbf', NULL), ('4fcd80ef-67ac-4853-abb6-d2c354e63785', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '4919222d-e1cc-4c86-b4ee-7fec73178816', NULL), ('24a9ec8e-6905-419e-ae76-af03d0e1113f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'd6d44711-e239-4eaf-a83c-b94f7e56002c', NULL), ('944a40b4-1d2a-4199-85f2-1e5c2a6196a6', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '201c9f83-37c0-4bae-8b2a-f2e6de5d956f', NULL), ('3c4f4f63-9c66-4651-9190-a5b226ad6080', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '8035da3c-aae2-42a1-8e4e-6cf10e25cad5', NULL), ('d451bea2-5ee1-4d71-9d17-d697f0a46ab0', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'c916e636-caca-4cbe-bd09-3a0859653c79', NULL), ('79bd4b8b-69da-4d11-b82f-ffbdc7f7e2f8', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'e1a88a3e-f67e-4440-896d-55506a5b37bd', NULL), ('7aa8d001-7181-4881-80d0-46182cfec74c', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '62c2432d-e057-40a7-8c6c-729698f94768', NULL), ('a6405a07-4682-4802-b891-9276281ad9a0', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'da21bd74-a16f-4edb-a78e-f94a7990800f', NULL), ('e9c17b81-0d36-4130-ba63-c2406b5b7921', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '9d984a4c-e6b7-4ad1-a2a9-fefc080e6b1c', NULL), ('ba2712a3-71ce-46e2-ac37-6c151c2e1113', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '51723e0e-90da-49e0-b2a1-18fcdd08fae0', NULL), ('78364b8f-2b80-4eda-9b47-8b4ad57e0b11', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '4a453f7d-ca02-4499-a96b-dbfcb11a97c0', NULL), ('1a1d3493-2084-4531-a4a3-8f3582c39236', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '29c8b40f-14d8-4c46-9262-b888b2792aec', NULL), ('94fc9c22-03db-4cfd-a214-c60836a6e376', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '7a85b64a-fd0b-41d4-900a-26892f03574b', NULL), ('734eaa3b-935d-4c8c-bbc3-9e8c6e7780f9', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'cd003266-7ba4-415d-bbb7-e05baf443dd8', NULL), ('7f6e4e6b-dd88-465b-8438-32e22c5056ba', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'f520eb22-8273-4cdf-b0db-3baab2eda655', NULL), ('1d8d7170-5b45-4926-a766-1ed6e2990d93', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '1daf96af-c734-433e-8c09-1e8363488ca2', NULL), ('553203c5-80e9-427e-b035-e580c408ea66', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'ed0f6602-3b8f-4cf4-a60d-fc7a37468254', NULL), ('bf854afa-0860-41ae-b423-15a5e9ceda73', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', 'ff16eebe-19dc-4668-87bd-a352ecda8ace', NULL), ('232532ea-a37e-4792-a4aa-5be9f32e796f', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '1e5667dc-cf8d-49ae-b8b6-565b28298aff', NULL), ('b33ea86f-9e60-4926-a2d0-4607d96e082e', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '7879033f-e0ac-4df6-bf9a-586b084f795e', NULL), ('25f80aea-a942-4c80-affb-31a4e3ba4ba1', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '1a239e12-d03c-4524-82ab-1094aa479930', NULL), ('5cdd3728-8ecf-4877-9dc8-8b9a1e95dfaa', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '9e880e44-b57b-41bc-8c85-0254c5c6688e', NULL), ('5506844b-1598-417d-9f34-923eea77a1e6', 'Tủ lạnh', '5000000', 'AQR-D100FA(BS)', 'good', '299720d2-1fc1-49f1-ae1c-398f0aad52c3', NULL), ('c49021b2-edef-4dec-90cd-250370f46def', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'e9fd906e-5655-4cf6-8d4f-7d4556243114', NULL), ('c4b7fd66-a08d-4d3e-bd43-5c4bf36011f8', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'a250f35d-5818-40bd-9def-9056a4f7f3ce', NULL), ('48e0a868-26e2-48b3-b122-53bfa9f35f01', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'f0c77063-f713-4b0f-94ad-4327b41a54b7', NULL), ('4e7dad9e-c4f3-4a77-a532-807dbce8721f', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '9eb60dc2-fccb-4c23-803a-a3914e359f13', NULL), ('389993be-de70-4143-bb14-5facb2abea11', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '26281e30-03c0-44cf-9dc7-fc3b772b82a7', NULL), ('970e0c96-29e0-4750-88ba-f4bc6ad5b89f', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'd61af8de-2636-48bf-bfb2-a7ba4c331dff', NULL), ('5167926b-15ae-48af-9645-0d574f2a19d4', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '7be0476c-eb64-44f3-83af-c2ca66fedce9', NULL), ('e41db1cc-238d-4ada-a8ef-28ca3969d53c', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '339f11ff-91e1-4a8d-b1c2-f56b8a50fc74', NULL), ('23a79f80-6190-4b14-ba9b-3923a7c7f72b', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '4ab7809f-e764-4df8-948c-b1e4164a1245', NULL), ('c65fca59-d5d7-4949-ada8-e122a3adabea', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'c0e09f3d-a6cd-4305-8a9d-6b40434c8c51', NULL), ('40347210-55af-4849-a5f2-dd5cbd022ba0', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '8dd30ed1-22ff-45ab-8067-b65f9d8d4ff8', NULL), ('eb4073f8-9d7f-4ed5-8558-d1efc193eb87', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'adaab164-cb3e-4c38-8665-4f87557fc73f', NULL), ('c0bdfa73-bb96-4f99-b682-ec9d5bb1ba94', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '226c1468-4a3c-48cd-ad5d-ed79dbaa0ce6', NULL), ('8f8f6a6a-f8d9-43af-82ef-75a106b5415b', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'fcdc926b-1e47-430c-838b-4feda05aeb09', NULL), ('339106b0-cfc3-4393-9b91-ea3c43b16aeb', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '839f071b-1bc1-4e6d-8544-57ddf5e42ded', NULL), ('7b467a68-70fa-437b-94a5-9d717d7c9338', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'c935b05d-d435-4db0-a623-21a2898db652', NULL), ('26271e29-73fc-47d3-a0f2-855cd2ead617', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', '03eac7c3-e8d6-471c-a48c-64132d963d6a', NULL), ('8a14a5b9-820d-4511-8d29-616c144dcb33', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'ef4c70ea-dd6e-4f72-813e-671994226012', NULL), ('d8e3aaed-00d0-4fa0-98d1-f1e2b9c43fc3', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', 'd6d44711-e239-4eaf-a83c-b94f7e56002c', NULL), ('643d6004-df5d-4d27-8d64-74bbc1ebc908', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('8c3218cf-ce27-4b1b-a8da-7e5861b5ff3b', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('a85fd48b-ef76-4645-b598-ef0155e5c415', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('a3b50c16-5cd9-48c7-8aae-31a70ef68809', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('29294a33-9d1a-40e3-916f-4bab06aea33f', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('bdb92cf1-7e8a-4124-8c77-4e576a0c7bf7', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('83c14768-de2f-43dc-b3a7-6766a930fd5c', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('f6e9cce2-84bb-499c-b872-e45252b4a863', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('094088f1-0d5d-4aca-9880-e0a16f775f2a', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('d4768816-0873-4120-80e8-ee27595e0dc4', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('73101d54-77a1-432c-9f89-d2fda48eaff1', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('b8d76265-2d0e-4a4f-a608-1a3b26938fca', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('3a2ed8aa-80aa-4027-8f5b-38804bea62ce', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('8ccc30bf-f482-48a4-b619-b974756323d7', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('4eb05eee-8a4e-4060-a5ff-b2c550a272d2', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('fb9ed0d2-588e-4beb-ba9e-097c4d38d2ea', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('887e47ee-1028-479a-aecd-b88c33607935', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('25bfa5b1-1ddd-4fa6-b0f0-61735b22623e', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('410f29fe-3dcb-411b-ba07-d65d3ebaac15', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('7afd5364-9217-4069-8c3c-140e0ac9f36c', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('89c1a3b8-4b09-40f8-adcb-f991e4110a3c', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('cbeb10da-1598-47fa-9954-676a860570da', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('029ac9b5-8602-4ecf-920c-0d7ec38ed23c', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('337069ec-582f-46f0-9009-186c5e2e4033', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('a6e55004-c88b-4e39-9b14-155066c40d07', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('5696d05e-6744-420d-8255-745439cf45b7', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('a3ed9feb-bfcc-47d6-bc1f-0f5cf329bc18', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('8d7ce0f6-a49b-4ce4-bbe6-554ef2bb6376', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('cdedc629-814b-43f3-b54d-a598a6e5c5d4', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('843954dc-aa00-422e-ae0f-ebf91eecd1c7', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('fe4dbb49-02d2-48ff-a6f7-02c899254a73', 'Máy giặt', '6000000', 'AQW-FR120HT BK', 'good', NULL, NULL), ('f5d911ff-954c-41b8-926d-9cc8112b4e84', 'Tivi', '15000000', 'AQT65S800UX', 'good', '1ef2149f-2f72-4e3c-9c35-3a049e62d8ff', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('6adffacd-79f2-4de8-be65-fe7ba98fd687', 'Tivi', '15000000', 'AQT65S800UX', 'good', '8cb5652e-3613-41a7-9f33-0549dcb1adce', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('2fe32f95-7981-414f-b887-5fc9c12dd172', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'e9fd906e-5655-4cf6-8d4f-7d4556243114', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e75b805f-28a4-486d-9c43-6665dc383c1f', 'Tivi', '15000000', 'AQT65S800UX', 'good', '8627801c-f14d-4a86-844e-73163eac571a', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('5d2604f3-5fd7-4391-b255-50d564442c24', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'a250f35d-5818-40bd-9def-9056a4f7f3ce', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('6d864c7f-04d8-4f41-b1a8-56618e867d99', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'a868b143-d2a3-48c8-a9e0-1ddd17f89441', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('6084c27c-4632-45c3-b115-62d4de58abf0', 'Tivi', '15000000', 'AQT65S800UX', 'good', '9987b36d-7dce-4d3b-971c-f951096545d4', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('0ce48677-451e-4df7-b662-0e6bc3b7bca7', 'Tivi', '15000000', 'AQT65S800UX', 'good', '08c9f188-457a-451d-91cc-81f51af8b92f', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('71851733-bf14-4204-b587-837ebe34eaeb', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'f0c77063-f713-4b0f-94ad-4327b41a54b7', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('78790a32-53a6-4cd7-989f-82fea864f590', 'Tivi', '15000000', 'AQT65S800UX', 'good', '73e69a97-3b87-4f19-9286-5013037cf94d', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('ef91b33d-c14c-469a-83ec-f848688d91e4', 'Tivi', '15000000', 'AQT65S800UX', 'good', '9eb60dc2-fccb-4c23-803a-a3914e359f13', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('20b836d8-42f7-40b1-94aa-b90bee017635', 'Tivi', '15000000', 'AQT65S800UX', 'good', '1df5902e-2795-4c0e-a6c1-45d69abf7d5c', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('9885ab04-7874-4a20-86c0-faa839d9d561', 'Tivi', '15000000', 'AQT65S800UX', 'good', '26281e30-03c0-44cf-9dc7-fc3b772b82a7', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('93fe46a5-b7ed-4330-8f65-1a588daaae7f', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'fe6f4efe-6553-4d8c-b895-80fa27246d20', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('31bcca05-d5ca-41a6-ae06-4037909c6421', 'Tivi', '15000000', 'AQT65S800UX', 'good', '987c8df6-4171-410b-97da-34c8de21dffa', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('3de909d0-ca2a-40be-a380-0c7aeb28edd8', 'Tivi', '15000000', 'AQT65S800UX', 'good', '632b2417-2af6-40a0-ab65-25d21e2d3861', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('88bece84-9751-4771-89bb-4fde68800a1e', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'd61af8de-2636-48bf-bfb2-a7ba4c331dff', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('711855b3-3bb3-4536-be64-d6457c3e312e', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'a958254a-24e9-4fff-bfe6-7040b569b9d0', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('9faf055d-16b0-424e-a41a-f11808f5643f', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'e57a204f-23d1-460c-ac07-69281e82b2f4', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('97979bb5-7e85-4661-a45a-8641cefba51d', 'Tivi', '15000000', 'AQT65S800UX', 'good', '48c6ef9e-37eb-4ba2-9c2d-f78bd3a2ead6', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('35eb4f54-26dd-42bb-b385-7a7d49b01607', 'Tivi', '15000000', 'AQT65S800UX', 'good', '019f2ab2-b53b-4d53-b772-0f7e1d48c4a6', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f91df42f-0d5e-44ae-8048-d5df84fde748', 'Tivi', '15000000', 'AQT65S800UX', 'good', '25c3f188-c0a5-4204-b19b-0122f7934346', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('fabfd112-ef66-4dfb-851c-9398a4a9f027', 'Tivi', '15000000', 'AQT65S800UX', 'good', '8a45b9a2-a878-45d5-b44c-1d0ba1198cdc', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('1f6f2c7f-0b8b-470a-a3ab-c0ae634aac86', 'Tivi', '15000000', 'AQT65S800UX', 'good', '7be0476c-eb64-44f3-83af-c2ca66fedce9', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('1e6224aa-bb3e-4e46-b857-b69135891f5d', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'e5b1450f-b40e-4eed-a4d4-5523aa4b5f3b', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('a0d4b272-62d6-464a-aa2a-38357b9a27a9', 'Tivi', '15000000', 'AQT65S800UX', 'good', '8f21ec70-3804-4b6e-82c4-c281c63bd367', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('2c8fa870-4273-4160-a1f7-ca1571ad94ef', 'Tivi', '15000000', 'AQT65S800UX', 'good', '7ca6f209-fce2-4964-be46-c6c75829ba3f', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('b7fb9628-1edf-4ff4-8a0f-4a9d9ced5cc8', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'b288415f-d11e-45a8-bd66-cf04fd98cf80', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('c3b063a6-7877-4f60-bb3b-8bc3a42fde43', 'Tivi', '15000000', 'AQT65S800UX', 'good', '3e091c8c-945a-4d6f-bc8d-f99b55aad2c2', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f3651f2b-0ccf-4dfa-8223-56d7fdf4604a', 'Tivi', '15000000', 'AQT65S800UX', 'good', '339f11ff-91e1-4a8d-b1c2-f56b8a50fc74', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e16e049b-8ee4-4f41-872f-fda1615db148', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'ed817e6f-1358-4167-9db7-8cf2531f3e53', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('75f06dca-bbe2-4c3c-ac3a-90e32dbe7783', 'Tivi', '15000000', 'AQT65S800UX', 'good', '54c627b4-887b-4c17-a7d8-7afcd43b7db2', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e96e5cba-ddd7-43f4-aeae-18d6fd62f251', 'Tivi', '15000000', 'AQT65S800UX', 'good', '4ab7809f-e764-4df8-948c-b1e4164a1245', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f3f92cfd-e6b4-485e-b002-18a20c99acc9', 'Tivi', '15000000', 'AQT65S800UX', 'good', '982beab5-2431-4f54-b826-5ac794449cd2', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('eec003ee-4da6-4dc2-b35f-eb0e3960074f', 'Tivi', '15000000', 'AQT65S800UX', 'good', '0a6e8fbf-00de-4756-bc05-a44fe89e09a8', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('2ba2d253-e4b3-41f7-8d37-1f3ab302b5dc', 'Tivi', '15000000', 'AQT65S800UX', 'good', '0ef0294d-af49-46fd-a2aa-46d2c919ab4b', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('6b508329-8b81-4a52-89da-e337cc76893e', 'Tivi', '15000000', 'AQT65S800UX', 'good', '6dc76e97-f347-4f1b-a391-da38ad26ca92', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('296433c2-d636-440c-9c23-5b3fd4e551d6', 'Tivi', '15000000', 'AQT65S800UX', 'good', '19a6bbe3-553a-4f25-82dd-2871213f9c8b', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('7db267bb-e0a6-446e-bb1d-109bffcabb32', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'a6024b97-08e1-4631-9a17-7db7dbb76761', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('d6407a6b-47d4-429a-b4ce-7b26c11ec330', 'Tivi', '15000000', 'AQT65S800UX', 'good', '6c2fc256-2bd0-4c6d-a4fa-68d386e11523', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('330312e2-f467-49ea-b9e9-1255a01f8840', 'Tivi', '15000000', 'AQT65S800UX', 'good', '5b603c38-1b6f-4f95-a796-4ced6600fdf8', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('7031385d-2953-4463-bd16-e05bc93f565f', 'Tivi', '15000000', 'AQT65S800UX', 'good', '3a3b6b6f-396c-447d-bb9f-77bf1bd56266', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('732433d6-a1cf-4f0a-8fc2-4ea17e0c1d0e', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'a3e3792b-7439-4237-a903-ffe8dd24b5eb', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('83b0e2f0-9fe7-4311-8476-f857d3b77dec', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'c0e09f3d-a6cd-4305-8a9d-6b40434c8c51', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('96b6a530-c46a-4106-bad2-2560e34a47ee', 'Tivi', '15000000', 'AQT65S800UX', 'good', '8dd30ed1-22ff-45ab-8067-b65f9d8d4ff8', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('866e2a08-cb4a-4451-a296-70a3081584b4', 'Tivi', '15000000', 'AQT65S800UX', 'good', '51d291d5-844a-4f12-b9d8-98d72ca468d3', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('1c0d6d34-011c-441c-9009-efc92e23e551', 'Tivi', '15000000', 'AQT65S800UX', 'good', '9d37e0f6-3981-4fe6-82f7-204e739c762e', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('fcc2cba8-2040-4a2c-8fa3-978fcd1b7be8', 'Tivi', '15000000', 'AQT65S800UX', 'good', '65ab4f2d-251d-4bcf-8d10-13b215a82cb2', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('46d82609-19a8-4605-800c-3f7cf699d4f2', 'Tivi', '15000000', 'AQT65S800UX', 'good', '2e31cb4b-11d8-4c24-8be3-c2ebf47ea6fe', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('a2bb88a2-fb28-478f-8942-7078b0f356ac', 'Tivi', '15000000', 'AQT65S800UX', 'good', '420c9af0-63f1-4e8d-a619-e39425bd621f', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('8b74b042-3a56-41cb-98f5-096d4762a008', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'adaab164-cb3e-4c38-8665-4f87557fc73f', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('5cc55ffa-f9f7-4e7a-af86-f97bba20ff53', 'Tivi', '15000000', 'AQT65S800UX', 'good', '68834c21-9d0a-4ac0-803a-c07d1a57cc85', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('d972a671-c044-4efc-bc54-172ecf0a2895', 'Tivi', '15000000', 'AQT65S800UX', 'good', '6ccd9968-eb06-4647-942c-82ca7590b756', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('a189483f-0070-4ac9-ba8d-d3b2343aac89', 'Tivi', '15000000', 'AQT65S800UX', 'good', '57280b0e-6dab-4592-8288-ff684955d6bc', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f1549d6e-dbd4-4a2c-bacd-c50e51d1abc3', 'Tivi', '15000000', 'AQT65S800UX', 'good', '54804511-0e29-424d-8662-3854ae0b3e94', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('cb3400b0-f910-413c-a1bf-0d6bedc71a77', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'f95ab7e4-ca69-40b3-99c8-f1f2bf7dcb97', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('6a728770-a642-437f-929a-6f91b86ca778', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'e0278fa4-2033-4ffd-b760-18a4077dd88a', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('198bc9e2-f4d0-415e-bcc6-f15fcb33b326', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'd32ffce7-e64d-4012-b826-775408179d51', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('00298f5b-bb40-4ccc-bdb3-7d033c05194e', 'Tivi', '15000000', 'AQT65S800UX', 'good', '3b480bb2-e072-4235-990f-82bf24465658', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('b8d359d3-b12e-42e2-97bc-b226382aa28a', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'ba9fa558-8edf-4930-be3b-a04248dcfb75', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('321ac935-a44b-4c35-afdf-ae02fc520b6e', 'Tivi', '15000000', 'AQT65S800UX', 'good', '2c3bc33a-6333-467e-bf22-7baf16ac166b', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('ec125321-132a-4b02-8bd6-e317da3952f5', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'f5b9abcb-54c9-4c32-b396-ea4f6eefbcc5', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('b6046b79-7e6f-4b4c-9e82-e4d16d77c0c7', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'def00d2e-bc04-404c-9dc5-7972fa52116c', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('63c5b7d4-a8ab-4cc7-8739-727b7bbff48a', 'Tivi', '15000000', 'AQT65S800UX', 'good', '4974ca03-9a6f-4ad7-b4c0-781bbfba0bac', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('c0950506-66fc-4153-aea0-b83d000406e1', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'd82c4483-f4f9-4d5a-a0b7-f338a542b65e', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f6cc193a-3551-4a05-bc9d-1b275b37df2c', 'Tivi', '15000000', 'AQT65S800UX', 'good', '226c1468-4a3c-48cd-ad5d-ed79dbaa0ce6', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('5f1032de-7440-4a97-a659-41b4711fd6ec', 'Tivi', '15000000', 'AQT65S800UX', 'good', '6ae0ad85-7d23-4514-895e-c83c7963107a', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('b11ee2d6-2b19-4a3c-873b-fa476875a705', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'c5ff94fc-998c-4855-acd3-ab844e6c69cd', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('1b9a2104-163a-4731-abb3-04f623328c61', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'fcdc926b-1e47-430c-838b-4feda05aeb09', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('701bd103-e70b-4538-b9b2-db4a1c5606db', 'Tivi', '15000000', 'AQT65S800UX', 'good', '3ab598d6-c400-48cf-ae8a-2d73c224720d', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('0768b5e1-526f-4558-86d7-2095a5261bf5', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'c316af3d-c57a-4718-9a09-f27a888b4540', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('aa9b52b3-0206-42bb-9b4d-d7238d798c5c', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'e989bf52-5919-4262-b24d-8b269c8f6fce', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('669b6e88-3f01-4206-9b7e-5f74dc2fc39f', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'f4e8114b-038f-4ef4-9cd4-0bc72fc4a61a', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('fb8f1a7c-7633-473a-a7aa-925e8a70a098', 'Tivi', '15000000', 'AQT65S800UX', 'good', '839f071b-1bc1-4e6d-8544-57ddf5e42ded', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('bd3b40ea-58a5-46dc-992c-3c93943b1ebf', 'Tivi', '15000000', 'AQT65S800UX', 'good', '4073470e-9a1c-47b4-b58d-e7208c45b5fe', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('c3da3a9a-418a-489e-8739-f6f4fe12f5a6', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'e618eb25-e1e0-44c7-881c-f2397f86ead4', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f2a1a66b-39e5-47d6-9838-3fa60a713900', 'Tivi', '15000000', 'AQT65S800UX', 'good', '73dbdb84-fac9-4898-8647-5698e9be565e', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('062c704e-934c-4748-8a26-1c5d697f774c', 'Tivi', '15000000', 'AQT65S800UX', 'good', '69ed59d1-d2e6-4ae4-837b-e5b0782fe847', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('04dfef65-ce7e-463b-96a2-e13f7f27b59e', 'Tivi', '15000000', 'AQT65S800UX', 'good', '812cf461-4041-43ed-be44-e984dd0e8141', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('c084b4f8-3581-4444-bb74-2f1b31fb572e', 'Tivi', '15000000', 'AQT65S800UX', 'good', '2fe02cc4-443d-496e-a985-7b8bd0809fd9', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('313bb096-593e-4aea-8baf-743d2cc5ee54', 'Tivi', '15000000', 'AQT65S800UX', 'good', '9a4bf058-9a47-44cb-b8ea-716985480fcf', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('a7623c24-0679-4a37-a088-3f4009244356', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'c935b05d-d435-4db0-a623-21a2898db652', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f1f3b4e4-ac23-451d-a9b1-a737e5c48dcc', 'Tivi', '15000000', 'AQT65S800UX', 'good', '00bbeed0-ef9b-468e-8c02-98b9e82ea6cd', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('bb361314-9e59-48b9-8557-c589bf318dd4', 'Tivi', '15000000', 'AQT65S800UX', 'good', '897e3b5c-d9d5-4ec7-ae4f-02517ad86304', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('62bf402a-5fdc-4f46-a27f-2e7dee7183e3', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'a0fc2c2d-93e2-438f-ab0e-3966ad8e26b3', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e7b234ba-2f1b-4b1a-a3c3-5afb3e218ff8', 'Tivi', '15000000', 'AQT65S800UX', 'good', '3924a391-dee2-47f2-a163-8b1393b44501', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('0d92af9b-0152-4013-8cc1-c6c7fa91b051', 'Tivi', '15000000', 'AQT65S800UX', 'good', '03eac7c3-e8d6-471c-a48c-64132d963d6a', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('7f5ba1bb-9860-44ce-89d7-67b1ebe58702', 'Tivi', '15000000', 'AQT65S800UX', 'good', '1cc3564e-d947-4325-bd62-5ae832e0a33d', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('11f25b93-e9fa-47d6-9f46-d6ac92a8c50a', 'Tivi', '15000000', 'AQT65S800UX', 'good', '97fd14dc-4fd6-40dc-aac4-30c9f00c7c86', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('f65cbcd2-7d15-4893-b957-b77ef66422c9', 'Tivi', '15000000', 'AQT65S800UX', 'good', '1fcc8d69-3f0e-4f41-b2b5-b61b4929f14b', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('a13604c4-c6af-4abc-a2bb-55e54d0f9899', 'Tivi', '15000000', 'AQT65S800UX', 'good', '83e77a6d-84f8-42ed-bcb0-6a877197ea5f', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('217130f2-0398-4b5f-b680-e00ff54753b6', 'Tivi', '15000000', 'AQT65S800UX', 'good', '9c8a49f0-fd01-4b5b-a54b-d60dadf99bcd', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('efbe21a6-2e7c-4f9d-8d43-b8fa657cb304', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'b8eb833b-760f-44da-b248-8b2206306d6b', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('635facfa-6799-470a-9529-a96d3e7d0287', 'Tivi', '15000000', 'AQT65S800UX', 'good', '4fabbaa7-c227-474b-919a-ee30bd8d715e', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e0e8df9f-7b9a-46c0-82b8-98ff9ec40edb', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'ef4c70ea-dd6e-4f72-813e-671994226012', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('835b3701-b6ef-4a20-a3d6-c67b9d7d38ca', 'Tivi', '15000000', 'AQT65S800UX', 'good', '8185a97f-abb0-4d33-a940-a11c66cec863', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('7d022112-0fe9-48a5-bced-0a5d28558f0b', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'f28e807c-529f-4232-bdf8-0bc78e1cebbf', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('7e319baa-e26e-435e-a164-80f7372efc33', 'Tivi', '15000000', 'AQT65S800UX', 'good', '4919222d-e1cc-4c86-b4ee-7fec73178816', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('def0bd07-58ac-4fd4-a39b-cb55dcf916ac', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'd6d44711-e239-4eaf-a83c-b94f7e56002c', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('b3019e45-b8dd-4467-8888-ece5d22ebebb', 'Tivi', '15000000', 'AQT65S800UX', 'good', '201c9f83-37c0-4bae-8b2a-f2e6de5d956f', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('55dd03b8-18bd-4a72-a519-2bb4fc4615d7', 'Tivi', '15000000', 'AQT65S800UX', 'good', '8035da3c-aae2-42a1-8e4e-6cf10e25cad5', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('ccc9ba09-51be-4845-8340-faa8c4575b5a', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'c916e636-caca-4cbe-bd09-3a0859653c79', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('989e43fd-0de8-4e0f-ba9c-31ca91c8f9d1', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'e1a88a3e-f67e-4440-896d-55506a5b37bd', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('26539965-969a-447f-a26d-c9797a974837', 'Tivi', '15000000', 'AQT65S800UX', 'good', '62c2432d-e057-40a7-8c6c-729698f94768', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('462db2f7-57ae-43a3-a652-da17940ace43', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'da21bd74-a16f-4edb-a78e-f94a7990800f', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('4ae59dfc-7e19-4d2f-8a8b-b89da4456e04', 'Tivi', '15000000', 'AQT65S800UX', 'good', '9d984a4c-e6b7-4ad1-a2a9-fefc080e6b1c', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('945f1d0c-ff38-4ef9-aabb-c71abe21fcc5', 'Tivi', '15000000', 'AQT65S800UX', 'good', '51723e0e-90da-49e0-b2a1-18fcdd08fae0', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('618927a1-3102-4bb3-bd97-6a8a03cda1b1', 'Tivi', '15000000', 'AQT65S800UX', 'good', '4a453f7d-ca02-4499-a96b-dbfcb11a97c0', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('58f74072-d046-4d9e-9c38-d4eec875a256', 'Tivi', '15000000', 'AQT65S800UX', 'good', '29c8b40f-14d8-4c46-9262-b888b2792aec', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('de765c2e-d888-4236-afc1-5bcd1cdcc0bf', 'Tivi', '15000000', 'AQT65S800UX', 'good', '7a85b64a-fd0b-41d4-900a-26892f03574b', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e2c8aefb-b403-4fec-a236-05c5894a17ef', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'cd003266-7ba4-415d-bbb7-e05baf443dd8', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('de9036c9-ca6c-4fe2-94bb-a495da1d98a9', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'f520eb22-8273-4cdf-b0db-3baab2eda655', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('918d8881-39ad-4157-bfe4-e699673d972f', 'Tivi', '15000000', 'AQT65S800UX', 'good', '1daf96af-c734-433e-8c09-1e8363488ca2', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('906f0cf9-0611-406a-81ab-b41cddbf507c', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'ed0f6602-3b8f-4cf4-a60d-fc7a37468254', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e7824582-9a3a-48ec-8bc4-12ab1d598569', 'Tivi', '15000000', 'AQT65S800UX', 'good', 'ff16eebe-19dc-4668-87bd-a352ecda8ace', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('be632ddb-692a-4504-80db-147607ca134e', 'Tivi', '15000000', 'AQT65S800UX', 'good', '1e5667dc-cf8d-49ae-b8b6-565b28298aff', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('30d9b981-c286-4bc6-913a-d8476075afab', 'Tivi', '15000000', 'AQT65S800UX', 'good', '7879033f-e0ac-4df6-bf9a-586b084f795e', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('38dc8584-fe37-42ce-b557-0e6a84eced7b', 'Tivi', '15000000', 'AQT65S800UX', 'good', '1a239e12-d03c-4524-82ab-1094aa479930', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('e5932cdb-b17d-49ac-b769-dd2019e0faeb', 'Tivi', '15000000', 'AQT65S800UX', 'good', '9e880e44-b57b-41bc-8c85-0254c5c6688e', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg'), ('17523852-aa50-4b34-a712-a79b1876bb97', 'Tivi', '15000000', 'AQT65S800UX', 'good', '299720d2-1fc1-49f1-ae1c-398f0aad52c3', 'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/1942/327172/google-tv-aqua-qled-4k-65-inch-aqt65s800ux-3-638645970392969071-700x467.jpg');


INSERT INTO NhanVien (ID, HoTen, GioiTinh, Luong, NgaySinh, MaBHXH, CCCD , SoTaiKhoan, VaiTro, ThoiGianBatDauLamViec, TrinhDoHocVan, MaChiNhanh) VALUES ('3f3075e5-bcaa-464c-ab7d-eab74e37331f', 'Dang Thanh Hien', 'Female', '13000000', '1992-08-19', 'BHXH01', '100000000001', '100000001', 'Receptionist', '2011-02-01', 'Cao đẳng', 'CN02'), ('cc37abfb-a381-4cae-882f-273a3c752dae', 'Ho Minh Chi', 'Male', '14000000', '1995-01-26', 'BHXH02', '100000000002', '100000002', 'House Keeper', '2012-03-01', 'Thạc sĩ', 'CN01'), ('9deb9d20-2135-4dde-91c3-8e8724441c8b', 'Vu Van Phong', 'Female', '15000000', '1999-06-12', 'BHXH03', '100000000003', '100000003', 'Room Employee', '2013-04-01', 'Đại học', 'CN02'), ('24f12e49-ae98-4174-b442-899e36ecf89c', 'Tran Gia Thao', 'Male', '16000000', '1999-07-18', 'BHXH04', '100000000004', '100000004', 'House Keeper', '2014-05-01', 'Cao đẳng', 'CN01'), ('1968c7c1-58b7-4829-8807-036f706d640a', 'Tran Khanh Thao', 'Female', '12000000', '1991-03-10', 'BHXH05', '100000000005', '100000005', 'Receptionist', '2015-06-01', 'Thạc sĩ', 'CN02'), ('33db38a0-dc35-45d1-a0bd-120443fad0a9', 'Nguyen Gia Quyen', 'Male', '13000000', '1992-08-03', 'BHXH06', '100000000006', '100000006', 'House Keeper', '2016-07-01', 'Đại học', 'CN02'), ('5c9a7ace-d648-4b0f-930d-b32e07504468', 'Le Quoc Son', 'Female', '14000000', '1998-03-22', 'BHXH07', '100000000007', '100000007', 'Room Employee', '2017-08-01', 'Cao đẳng', 'CN02'), ('b042b9c4-3592-4777-80f6-e45ade39ae50', 'Dang Thi An', 'Male', '15000000', '1995-06-07', 'BHXH08', '100000000008', '100000008', 'House Keeper', '2018-09-01', 'Thạc sĩ', 'CN02'), ('630f5c5f-a6ac-4445-a970-d9b3f5d7fa8c', 'Tran Ngoc Hien', 'Female', '16000000', '1999-11-12', 'BHXH09', '100000000009', '100000009', 'Receptionist', '2019-01-01', 'Đại học', 'CN02'), ('1596552d-af04-4442-bb9c-9fcb373e5a65', 'Pham Thanh Quyen', 'Male', '12000000', '1997-07-27', 'BHXH10', '100000000010', '100000010', 'House Keeper', '2020-02-01', 'Cao đẳng', 'CN01'), ('e0e07554-6e4d-4a8d-8cbf-21464fcb990d', 'Dang Thi Trung', 'Female', '13000000', '1998-04-02', 'BHXH11', '100000000011', '100000011', 'Room Employee', '2021-03-01', 'Thạc sĩ', 'CN01'), ('5c9f2a5a-e0f1-48a9-a817-aaeb5272942f', 'Nguyen Khanh Chi', 'Male', '14000000', '1992-04-19', 'BHXH12', '100000000012', '100000012', 'House Keeper', '2022-04-01', 'Đại học', 'CN01'), ('a7555448-2673-4c8e-8591-065a7731563c', 'Hoang Thanh Huy', 'Female', '15000000', '1995-10-18', 'BHXH13', '100000000013', '100000013', 'Receptionist', '2023-05-01', 'Cao đẳng', 'CN02'), ('0ca3c07e-53d7-4e80-a093-2badf63062d7', 'Hoang Thi Son', 'Male', '16000000', '1993-09-16', 'BHXH14', '100000000014', '100000014', 'House Keeper', '2010-06-01', 'Thạc sĩ', 'CN02'), ('51b6ea0d-3c12-4a0a-bc5d-f90786009d48', 'Vu Thanh Hang', 'Female', '12000000', '1998-05-09', 'BHXH15', '100000000015', '100000015', 'Room Employee', '2011-07-01', 'Đại học', 'CN02'), ('a6ab95ea-6e30-4076-a368-ff073bb24463', 'Tran Gia Linh', 'Male', '13000000', '1992-08-09', 'BHXH16', '100000000016', '100000016', 'House Keeper', '2012-08-01', 'Cao đẳng', 'CN02'), ('3fed6ccc-dcfc-4fff-8ce4-39bd9485636b', 'Le Thi Son', 'Female', '14000000', '1993-12-23', 'BHXH17', '100000000017', '100000017', 'Receptionist', '2013-09-01', 'Thạc sĩ', 'CN02'), ('61ab47b5-6e7f-453e-aec9-4405a0b3afba', 'Pham Gia Nam', 'Male', '15000000', '1991-05-17', 'BHXH18', '100000000018', '100000018', 'House Keeper', '2014-01-01', 'Đại học', 'CN01'), ('89d33e65-4c6d-45e6-b3da-d6224ebf094a', 'Tran Van Hang', 'Female', '16000000', '1993-06-15', 'BHXH19', '100000000019', '100000019', 'Room Employee', '2015-02-01', 'Cao đẳng', 'CN02'), ('9b69a43a-1ca9-440e-b433-d91b935bab84', 'Pham Van Binh', 'Male', '12000000', '1991-10-14', 'BHXH20', '100000000020', '100000020', 'House Keeper', '2016-03-01', 'Thạc sĩ', 'CN02'), ('53eb6ab6-524d-47e3-9316-a3b91d7bbcad', 'Tran Minh Huy', 'Female', '13000000', '1999-06-22', 'BHXH21', '100000000021', '100000021', 'Receptionist', '2017-04-01', 'Đại học', 'CN01'), ('8104e848-3ee1-4aab-8b92-23ab124993e0', 'Vu Gia Quyen', 'Male', '14000000', '1996-02-14', 'BHXH22', '100000000022', '100000022', 'House Keeper', '2018-05-01', 'Cao đẳng', 'CN02'), ('37e84042-334a-451e-93a2-bb003d8cec29', 'Hoang Minh Lan', 'Female', '15000000', '1997-01-07', 'BHXH23', '100000000023', '100000023', 'Room Employee', '2019-06-01', 'Thạc sĩ', 'CN01'), ('3aee9bd2-4643-4fcc-aa88-117f08dd6ac6', 'Ho Thanh Trung', 'Male', '16000000', '1992-08-19', 'BHXH24', '100000000024', '100000024', 'House Keeper', '2020-07-01', 'Đại học', 'CN02'), ('26321118-4d4a-4a73-8fd0-400952518964', 'Do Van Thao', 'Female', '12000000', '1990-10-21', 'BHXH25', '100000000025', '100000025', 'Receptionist', '2021-08-01', 'Cao đẳng', 'CN01'), ('3432a14b-6a61-4c72-8584-22ed23970c4c', 'Pham Gia Thao', 'Male', '13000000', '1991-07-13', 'BHXH26', '100000000026', '100000026', 'House Keeper', '2022-09-01', 'Thạc sĩ', 'CN01'), ('cf7d4543-95ae-4980-901e-3878002d54d6', 'Pham Khanh Nam', 'Female', '14000000', '1999-06-26', 'BHXH27', '100000000027', '100000027', 'Room Employee', '2023-01-01', 'Đại học', 'CN01'), ('1533b26f-d54a-41ad-a14b-67946c55c606', 'Hoang Duc An', 'Male', '15000000', '1994-01-28', 'BHXH28', '100000000028', '100000028', 'House Keeper', '2010-02-01', 'Cao đẳng', 'CN01'), ('10f20ba3-3d3d-45a8-a30d-f981dcd4953e', 'Pham Gia Huy', 'Female', '16000000', '1996-03-21', 'BHXH29', '100000000029', '100000029', 'Receptionist', '2011-03-01', 'Thạc sĩ', 'CN02'), ('fcf13ad4-a334-4c39-b912-ec701d3044e8', 'Dang Van Hang', 'Male', '12000000', '1994-01-04', 'BHXH30', '100000000030', '100000030', 'House Keeper', '2012-04-01', 'Đại học', 'CN01'), ('b00d9f52-e7fa-432c-863f-01b99fcc9ac8', 'Ho Khanh Binh', 'Female', '13000000', '1991-06-17', 'BHXH31', '100000000031', '100000031', 'Room Employee', '2013-05-01', 'Cao đẳng', 'CN02'), ('f62f76e3-7cf7-4aa0-b15a-44ae18421777', 'Dang Gia Thao', 'Male', '14000000', '1994-06-28', 'BHXH32', '100000000032', '100000032', 'Room Employee', '2014-06-01', 'Thạc sĩ', 'CN01'), ('f252946e-acf2-4abc-93b7-b539e6e43c89', 'Ho Thi Dung', 'Female', '15000000', '1990-12-27', 'BHXH33', '100000000033', '100000033', 'Receptionist', '2015-07-01', 'Đại học', 'CN01'), ('15abcec8-fcbe-416b-81a4-bb00df96d764', 'Hoang Duc Hang', 'Male', '16000000', '1993-07-27', 'BHXH34', '100000000034', '100000034', 'House Keeper', '2016-08-01', 'Cao đẳng', 'CN02'), ('3ee36458-f483-4d15-8d91-8fdf1a0eb331', 'Nguyen Van Hang', 'Female', '12000000', '1994-01-26', 'BHXH35', '100000000035', '100000035', 'Room Employee', '2017-09-01', 'Thạc sĩ', 'CN02'), ('47983fa9-0d4f-4cf5-ae68-17f9f4ba7929', 'Do Quoc Hang', 'Male', '13000000', '1995-08-19', 'BHXH36', '100000000036', '100000036', 'Room Employee', '2018-01-01', 'Đại học', 'CN02'), ('de2f9e5c-3387-4f90-a51f-2990fd3453b7', 'Do Thanh Thao', 'Female', '14000000', '1990-10-04', 'BHXH37', '100000000037', '100000037', 'Receptionist', '2019-02-01', 'Cao đẳng', 'CN02'), ('046b970e-7a29-4bef-8967-e96bd0487b13', 'Le Duc Dung', 'Male', '15000000', '1991-07-20', 'BHXH38', '100000000038', '100000038', 'House Keeper', '2020-03-01', 'Thạc sĩ', 'CN01'), ('1aeda3e8-7a9e-42c1-b1db-53bec3728707', 'Tran Minh Lan', 'Female', '16000000', '1999-04-16', 'BHXH39', '100000000039', '100000039', 'Room Employee', '2021-04-01', 'Đại học', 'CN01'), ('b09bc393-b965-44f9-9450-a27739a0ee19', 'Pham Gia Huy', 'Male', '12000000', '1995-04-23', 'BHXH40', '100000000040', '100000040', 'House Keeper', '2022-05-01', 'Cao đẳng', 'CN02'), ('e586e485-2b9c-4fd9-91de-e740e3b76b7c', 'Dang Thanh Quyen', 'Female', '13000000', '1992-10-24', 'BHXH41', '100000000041', '100000041', 'Receptionist', '2023-06-01', 'Thạc sĩ', 'CN01'), ('a4bb1536-9d9a-4cef-a1a4-b7d02304855b', 'Le Minh Phong', 'Male', '14000000', '1992-03-28', 'BHXH42', '100000000042', '100000042', 'House Keeper', '2010-07-01', 'Đại học', 'CN02'), ('3a7a0d74-6ef7-418d-b40b-5836fa751c8d', 'Do Van Thao', 'Female', '15000000', '1991-09-02', 'BHXH43', '100000000043', '100000043', 'Room Employee', '2011-08-01', 'Cao đẳng', 'CN01'), ('b872fbe5-ce08-40d9-aec6-178197b7d301', 'Tran Minh Thao', 'Male', '16000000', '1991-07-07', 'BHXH44', '100000000044', '100000044', 'House Keeper', '2012-09-01', 'Thạc sĩ', 'CN01'), ('45a37523-d8b1-4c0a-b9ed-17efaf4046c6', 'Dang Thi An', 'Female', '12000000', '1999-01-05', 'BHXH45', '100000000045', '100000045', 'Receptionist', '2013-01-01', 'Đại học', 'CN02'), ('65b53ffd-b530-47b3-b6b8-10aabf13600b', 'Ho Ngoc Huy', 'Male', '13000000', '1993-06-09', 'BHXH46', '100000000046', '100000046', 'House Keeper', '2014-02-01', 'Cao đẳng', 'CN02'), ('62e60b80-1305-426b-ab6a-afc29b556029', 'Tran Ngoc Hang', 'Female', '14000000', '1998-05-19', 'BHXH47', '100000000047', '100000047', 'Room Employee', '2015-03-01', 'Thạc sĩ', 'CN01'), ('c6d7075c-a6a2-46da-8a5a-06dc09b10459', 'Do Thanh Huy', 'Male', '15000000', '1997-10-06', 'BHXH48', '100000000048', '100000048', 'House Keeper', '2016-04-01', 'Đại học', 'CN01'), ('51050607-2ecb-44ac-8ddd-3a3e4ee00c30', 'Pham Khanh Dung', 'Female', '16000000', '1995-11-23', 'BHXH49', '100000000049', '100000049', 'Receptionist', '2017-05-01', 'Cao đẳng', 'CN01'), ('814efc6b-b6ea-4957-b3a9-a984ac64a16f', 'Le Thanh Son', 'Male', '12000000', '1993-08-08', 'BHXH50', '100000000050', '100000050', 'House Keeper', '2018-06-01', 'Thạc sĩ', 'CN02'), ('daffbfde-4b35-46d6-bef4-89c536214203', 'Tran Thanh Hien', 'Female', '13000000', '1999-01-24', 'BHXH51', '100000000051', '100000051', 'Room Employee', '2019-07-01', 'Đại học', 'CN01'), ('d0e7b071-6799-418a-85a3-5b8dd24b615f', 'Le Van Hang', 'Male', '14000000', '1994-05-09', 'BHXH52', '100000000052', '100000052', 'House Keeper', '2020-08-01', 'Cao đẳng', 'CN01'), ('a9761c50-e770-4ab1-bf76-ccc108342cc7', 'Pham Minh Quyen', 'Female', '15000000', '1998-08-09', 'BHXH53', '100000000053', '100000053', 'Receptionist', '2021-09-01', 'Thạc sĩ', 'CN02'), ('20b945bc-c489-438b-b7d1-2fdb7cc0522e', 'Tran Duc Dung', 'Male', '16000000', '1994-02-14', 'BHXH54', '100000000054', '100000054', 'House Keeper', '2022-01-01', 'Đại học', 'CN02'), ('11f1d173-7a9d-4e55-b5ad-e94e7b36db12', 'Do Van Lan', 'Female', '12000000', '1991-10-17', 'BHXH55', '100000000055', '100000055', 'Room Employee', '2023-02-01', 'Cao đẳng', 'CN01'), ('d04f7842-ad6b-42f0-bc5f-08cbe76e7a01', 'Do Khanh Chi', 'Male', '13000000', '1996-10-05', 'BHXH56', '100000000056', '100000056', 'House Keeper', '2010-03-01', 'Thạc sĩ', 'CN02'), ('4363f0be-0acb-472b-8e35-2775b46c54d3', 'Vu Khanh An', 'Female', '14000000', '1992-04-23', 'BHXH57', '100000000057', '100000057', 'Receptionist', '2011-04-01', 'Đại học', 'CN01'), ('75bd62a5-2d92-4055-9af6-517094a5c0cb', 'Hoang Quoc Thao', 'Male', '15000000', '1995-01-20', 'BHXH58', '100000000058', '100000058', 'House Keeper', '2012-05-01', 'Cao đẳng', 'CN01'), ('0d959916-23e6-43dd-a91c-b7338f4fca69', 'Do Quoc Huy', 'Female', '16000000', '1999-03-28', 'BHXH59', '100000000059', '100000059', 'Room Employee', '2013-06-01', 'Thạc sĩ', 'CN01'), ('1fbe5169-7822-4b4f-96bf-ed74c3286f5f', 'Pham Ngoc Dung', 'Male', '12000000', '1994-04-16', 'BHXH60', '100000000060', '100000060', 'House Keeper', '2014-07-01', 'Đại học', 'CN01'), ('88844af4-a7e5-44ba-a353-6235679af1b9', 'Dang Van An', 'Female', '13000000', '1991-06-10', 'BHXH61', '100000000061', '100000061', 'Receptionist', '2015-08-01', 'Cao đẳng', 'CN01'), ('0729a94e-9fab-4a87-912f-b8fbf9277954', 'Do Thanh Thao', 'Male', '14000000', '1990-03-09', 'BHXH62', '100000000062', '100000062', 'House Keeper', '2016-09-01', 'Thạc sĩ', 'CN02'), ('2278f6cc-fb99-49f2-9afe-7ef72b6331ae', 'Vu Gia Huy', 'Female', '15000000', '1999-07-11', 'BHXH63', '100000000063', '100000063', 'Room Employee', '2017-01-01', 'Đại học', 'CN02'), ('47e80d0b-65b1-4701-ae91-841823697a3e', 'Pham Duc Thao', 'Male', '16000000', '1999-06-15', 'BHXH64', '100000000064', '100000064', 'House Keeper', '2018-02-01', 'Cao đẳng', 'CN02'), ('b53e8ced-43b8-480d-b128-873b0b3e2fb9', 'Le Van Huy', 'Female', '12000000', '1993-08-04', 'BHXH65', '100000000065', '100000065', 'Receptionist', '2019-03-01', 'Thạc sĩ', 'CN02'), ('198d9398-62a4-45eb-8500-b86cce2453ea', 'Vu Minh Huy', 'Male', '13000000', '1991-03-01', 'BHXH66', '100000000066', '100000066', 'House Keeper', '2020-04-01', 'Đại học', 'CN02'), ('a5dfc577-02d9-4902-943d-c3a56bf0f058', 'Nguyen Ngoc Linh', 'Female', '14000000', '1992-10-25', 'BHXH67', '100000000067', '100000067', 'Room Employee', '2021-05-01', 'Cao đẳng', 'CN02'), ('9f27821d-5f87-445e-bf8e-ab5067ae0a3f', 'Tran Khanh Trung', 'Male', '15000000', '1996-07-05', 'BHXH68', '100000000068', '100000068', 'House Keeper', '2022-06-01', 'Thạc sĩ', 'CN02'), ('d3995466-b2b5-40b7-92ec-edfbf62cb365', 'Nguyen Gia Binh', 'Female', '16000000', '1991-06-25', 'BHXH69', '100000000069', '100000069', 'Receptionist', '2023-07-01', 'Đại học', 'CN01'), ('93f897b5-ed58-4bf7-b79f-ab1fcf219e27', 'Vu Khanh Phong', 'Male', '12000000', '1994-06-22', 'BHXH70', '100000000070', '100000070', 'House Keeper', '2010-08-01', 'Cao đẳng', 'CN02'), ('3d61d13f-b261-4ede-b8f4-3a3c71a5b400', 'Le Van Lan', 'Female', '13000000', '1995-07-27', 'BHXH71', '100000000071', '100000071', 'Room Employee', '2011-09-01', 'Thạc sĩ', 'CN01'), ('244da7b2-d420-4280-826d-5927e111b0c8', 'Dang Thanh Nam', 'Male', '14000000', '1997-02-12', 'BHXH72', '100000000072', '100000072', 'House Keeper', '2012-01-01', 'Đại học', 'CN02'), ('eb814868-26d8-4826-a919-43f87820d25d', 'Dang Ngoc Hang', 'Female', '15000000', '1996-05-16', 'BHXH73', '100000000073', '100000073', 'Receptionist', '2013-02-01', 'Cao đẳng', 'CN01'), ('a9590d22-9a2a-4d0d-b2fd-a04832bd8cf6', 'Vu Duc Linh', 'Male', '16000000', '1991-04-16', 'BHXH74', '100000000074', '100000074', 'House Keeper', '2014-03-01', 'Thạc sĩ', 'CN01'), ('6c8ad546-8813-4dbf-beba-2d8cb765e371', 'Tran Minh Linh', 'Female', '12000000', '1990-05-21', 'BHXH75', '100000000075', '100000075', 'Room Employee', '2015-04-01', 'Đại học', 'CN02'), ('a87b0902-1437-4a6f-92d9-248cc74b7405', 'Vu Duc Linh', 'Male', '13000000', '1990-09-22', 'BHXH76', '100000000076', '100000076', 'Room Employee', '2016-05-01', 'Cao đẳng', 'CN02'), ('ecff16c2-0851-4478-945e-e5a725c3a877', 'Pham Thi Hang', 'Female', '14000000', '1998-10-17', 'BHXH77', '100000000077', '100000077', 'Receptionist', '2017-06-01', 'Thạc sĩ', 'CN01'), ('dff3b1a8-7c56-420a-a2f1-3b9f8443f3fb', 'Vu Ngoc Son', 'Male', '15000000', '1996-03-12', 'BHXH78', '100000000078', '100000078', 'House Keeper', '2018-07-01', 'Đại học', 'CN01'), ('b9968bd9-c472-4d05-aa55-95a1f9b8b227', 'Hoang Duc Phong', 'Female', '16000000', '1991-11-26', 'BHXH79', '100000000079', '100000079', 'Room Employee', '2019-08-01', 'Cao đẳng', 'CN02'), ('d0ff1cdd-4dbe-40d5-8432-04e7d30b6eb8', 'Dang Ngoc Binh', 'Male', '12000000', '1990-11-19', 'BHXH80', '100000000080', '100000080', 'Room Employee', '2020-09-01', 'Thạc sĩ', 'CN02'), ('65178479-eefa-4774-a6b4-67e940108f6d', 'Nguyen Minh Dung', 'Female', '13000000', '1996-11-24', 'BHXH81', '100000000081', '100000081', 'Receptionist', '2021-01-01', 'Đại học', 'CN01'), ('20b1f27e-87c5-45ba-ac61-21f150e871ff', 'Do Thanh Dung', 'Male', '14000000', '1991-02-02', 'BHXH82', '100000000082', '100000082', 'House Keeper', '2022-02-01', 'Cao đẳng', 'CN01'), ('8d8e3ee9-5853-4cfa-a3ed-fe4b758cc062', 'Le Thanh Lan', 'Female', '15000000', '1990-06-14', 'BHXH83', '100000000083', '100000083', 'Room Employee', '2023-03-01', 'Thạc sĩ', 'CN02'), ('8cc9de75-b166-4b1c-9bee-cb147ea0bd72', 'Hoang Khanh Thao', 'Male', '16000000', '1993-09-07', 'BHXH84', '100000000084', '100000084', 'House Keeper', '2010-04-01', 'Đại học', 'CN01'), ('567ab487-e7b9-48c9-b2d3-bda17fbf8664', 'Nguyen Thi Thao', 'Female', '12000000', '1995-03-04', 'BHXH85', '100000000085', '100000085', 'Receptionist', '2011-05-01', 'Cao đẳng', 'CN01'), ('da5372e0-6eb4-4842-8601-d0e8e3f65ba7', 'Ho Minh Thao', 'Male', '13000000', '1990-09-27', 'BHXH86', '100000000086', '100000086', 'House Keeper', '2012-06-01', 'Thạc sĩ', 'CN02'), ('5e664028-3242-419f-a868-0baefd5ab13a', 'Vu Ngoc Thao', 'Female', '14000000', '1996-12-24', 'BHXH87', '100000000087', '100000087', 'Room Employee', '2013-07-01', 'Đại học', 'CN01'), ('810b16cb-d2e7-473e-aed4-fd2421f07286', 'Nguyen Khanh Son', 'Male', '15000000', '1991-09-04', 'BHXH88', '100000000088', '100000088', 'Room Employee', '2014-08-01', 'Cao đẳng', 'CN01'), ('4a9d3f1e-dfb0-4e42-ad4a-88e69d54f5cc', 'Hoang Van Phong', 'Female', '16000000', '1991-09-28', 'BHXH89', '100000000089', '100000089', 'Receptionist', '2015-09-01', 'Thạc sĩ', 'CN02'), ('a92067cd-a40a-4fb2-aef4-1ced9a4b415d', 'Ho Gia Linh', 'Male', '12000000', '1995-03-11', 'BHXH90', '100000000090', '100000090', 'House Keeper', '2016-01-01', 'Đại học', 'CN02'), ('e0e152e8-beec-4691-9c75-b6649253b4c7', 'Le Gia Binh', 'Female', '13000000', '1996-07-24', 'BHXH91', '100000000091', '100000091', 'Room Employee', '2017-02-01', 'Cao đẳng', 'CN02'), ('8f2d493f-93b4-4f1d-971d-ddf0eaeca29a', 'Dang Quoc Quyen', 'Male', '14000000', '1991-06-09', 'BHXH92', '100000000092', '100000092', 'Room Employee', '2018-03-01', 'Thạc sĩ', 'CN02'), ('0f895c4a-084d-4eb9-8a0f-d3e2ae7ac03d', 'Le Khanh Trung', 'Female', '15000000', '1996-06-15', 'BHXH93', '100000000093', '100000093', 'Receptionist', '2019-04-01', 'Đại học', 'CN02'), ('49203171-4fb3-4b96-84cc-a1bfa1efbd19', 'Tran Duc Binh', 'Male', '16000000', '1999-11-12', 'BHXH94', '100000000094', '100000094', 'House Keeper', '2020-05-01', 'Cao đẳng', 'CN01'), ('491b3d15-bf2f-459c-b7fd-0c7957617dd2', 'Do Ngoc Hien', 'Female', '12000000', '1995-05-21', 'BHXH95', '100000000095', '100000095', 'Room Employee', '2021-06-01', 'Thạc sĩ', 'CN02'), ('b68b315d-ab9e-4fc6-acb1-b5307a71fb58', 'Ho Gia Linh', 'Male', '13000000', '1998-12-26', 'BHXH96', '100000000096', '100000096', 'Room Employee', '2022-07-01', 'Đại học', 'CN01'), ('e67473d7-0c70-4c06-ba39-bd08d045a1d2', 'Do Van Huy', 'Female', '14000000', '1990-12-12', 'BHXH97', '100000000097', '100000097', 'Receptionist', '2023-08-01', 'Cao đẳng', 'CN01'), ('537c658b-83b0-4a8b-bbce-f2be15fc2825', 'Hoang Van Linh', 'Male', '15000000', '1992-05-08', 'BHXH98', '100000000098', '100000098', 'House Keeper', '2010-09-01', 'Thạc sĩ', 'CN02'), ('21113e8b-d6f1-4db4-be1a-97c2abfc4a5b', 'Do Khanh Son', 'Female', '16000000', '1992-12-17', 'BHXH99', '100000000099', '100000099', 'Room Employee', '2011-01-01', 'Đại học', 'CN01'), ('2106e43f-3902-4ed5-851b-1edab0b18616', 'Ho Khanh Linh', 'Male', '12000000', '1997-10-06', 'BHXH100', '100000000100', '100000100', 'Room Employee', '2012-02-01', 'Cao đẳng', 'CN01');


INSERT INTO DichVuAnUong (MaDichVu, MucGia, MoTa)
VALUES
('AU01', 50000, 'Món ăn này hơi ngon'),
('AU02', 60000, 'Món này cũng ngon');

INSERT INTO DichVuDuaDon (MaDichVu, LoaiXe, MucGia, MoTa)
VALUES
('DD01', 'Xe 4 chỗ', 100000, 'xe chỉ chở 4 người'),
('DD02', 'Xe 7 chỗ', 200000, 'xe chỉ chở 7 người');

INSERT INTO DichVuGiatUi (MaDichVu, TuyChonGiat, MucGia, MoTa)
VALUES
('GU01', 'Giặt sạch', 100000, 'Giặt siêu sạch'),
('GU02', 'Giặt vừa vừa', 50000, 'Giặt sạch vừa vừa');

INSERT INTO DichVuPhongHop (MaDichVu, SucChua, MucGia, MoTa)
VALUES
('PH01', 20, 200000, 'Họp thoải mái'),
('PH02', 50, 500000, 'Họp thoải mái');


INSERT INTO ChuongTrinhGiamGia (MaGiamGia, ThoiGianBatDau, ThoiGianKetThuc, PhanTramGiamGia)
VALUES
('GG01', '2024-12-01 00:00:00', '2024-12-31 23:59:59', 50),
('GG02', '2025-01-01 00:00:00', '2025-01-31 23:59:59', 60);

-- INSERT INTO KhachHang (ID, Ten, CCCD, SoDienThoai, NgaySinh, GioiTinh)
-- VALUES
-- ('KH01', 'anh thái', '000000000000', '1111111111', '2004-02-03', 'Nam'),
-- ('KH02', 'chị thái', '222222222222', '3333333333', '2004-02-04', 'Nữ');

-- INSERT INTO NhanVien (ID, HoTen, GioiTinh, Luong, NgaySinh, MaBHXH, CCCD, SoTaiKhoan, ThoiGianBatDauLamViec, TrinhDoHocVan, MaChiNhanh)
-- VALUES
-- ('NV01', 'Nguyễn A', 'Male', 1500000000.00, '2004-02-05', 'BHXH01', '011234556789', '05022004', '2020-01-01', 'Đại học', 'CN01'),
-- ('NV02', 'Nguyễn B', 'Male', 12000000.00, '2004-02-06', 'BHXH02', '099876554321', '987654321', '2021-02-01', 'Đại học', 'CN01'),
-- ('NV03', 'Nguyễn C', 'Female', 10000000.00, '2004-02-06', 'BHXH03', '088987665432', '987654321', '2021-02-01', 'Đại học', 'CN01'),
-- ('NV04', 'Nguyễn D', 'Female', 10000000.00, '2004-02-06', 'BHXH04', '000897665465', '987654321', '2021-02-01', 'Đại học', 'CN01');

-- INSERT INTO SoDienThoaiNhanVien (IDNhanVien, SoDienThoai)
-- VALUES
-- ('NV01', '0899781007'),
-- ('NV01', '0933261004'),
-- ('NV02', '0935234007'),
-- ('NV03', '0931231007'),
-- ('NV04', '0987654321');

-- INSERT INTO NhanVienVeSinh (ID) 
-- VALUES 
-- ('NV02');

-- INSERT INTO LeTan (ID) 
-- VALUES 
-- ('NV03');

-- INSERT INTO QuanLy (ID, MaChiNhanh) 
-- VALUES 
-- ('NV01', 'CN01');

-- INSERT INTO NhanVienPhong (ID) 
-- VALUES 
-- ('NV04');


-- INSERT INTO LichSuSuaChuaBaoDuong (ID, ChiPhi, NgaySuaChua, MoTa, Loai, IDTienNghi_CoSoVatChat) 
-- VALUES 
-- ('LS01', 500000, '2024-11-01', 'Sửa chữa máy điều hòa', 'Sửa chữa', 'TN01'),
-- ('LS02', 300000, '2024-10-15', 'Bảo trì máy nước nóng', 'Bảo dưỡng', 'TN02');

-- INSERT INTO TienNghiPhong (ID, Ten, MoTa) 
-- VALUES 
-- ('TN01', 'Điều hòa', 'Máy điều hòa mát mẻ'),
-- ('TN02', 'Máy nước nóng', 'Máy nước nóng ấm áp');




-- INSERT INTO TienNghiKhachSan (ID, Ten, MoTa, MaChiNhanh) 
-- VALUES 
-- ('TNK01', 'Hồ bơi', 'Hồ bơi ngoài trời', 'CN01'),
-- ('TNK02', 'Thang máy', 'Thang máy đi qua các tầng', 'CN01');

-- INSERT INTO BanBaoCaoPhong (ID, ThoiGian, NoiDung) 
-- VALUES 
-- ('BBP01', '2024-11-25 10:00:00', 'Báo cáo phòng 101 bị hỏng điều hòa'),
-- ('BBP02', '2024-11-26 14:30:00', 'Báo cáo phòng 202 cần sửa chữa cửa sổ');

-- INSERT INTO CoSoVatChatHuHao (ID, GiaDenBu, MoTa, MaBanBaoCaoPhong) 
-- VALUES 
-- ('CS01', 200000, 'Điều hòa bị hỏng', 'BBP01'),
-- ('CS02', 150000, 'Cửa sổ bị vỡ', 'BBP02');



-- INSERT INTO Phong (MaPhong, MaChiNhanh, TrangThai, LoaiPhong, SoPhong, MoTa, IDNhanVienDonPhong, IDNhanVienPhong, IDGiamGia, SucChua, MaPhongLienKet)
-- VALUES 
-- ('P101', 'CN01', 'empty', 'normal', 1, 'Phòng có 1 giường đơn', 'NV02', 'NV04', null, 1, null),
-- ('P102', 'CN01', 'empty', 'normal', 2, 'Phòng có 2 giường', 'NV02', 'NV04', null, 4, 'P101'),
-- ('P103', 'CN01', 'empty', 'vip', 1, 'Phòng có 1 giường', 'NV02', 'NV04', null, 1, null),
-- ('P104', 'CN01', 'empty', 'vip', 2, 'Phòng có 2 giường', 'NV02', 'NV04', null, 2, null);



-- INSERT INTO DoTieuDung (ID, TenSanPham, SoLuong, GiaNhapDonVi, GiaBanDonVi)
-- VALUES
-- ('DT01', 'Nước suối', 10, 10000, 15000),
-- ('DT02', 'Snack', 5, 5000, 10000);

-- INSERT INTO BangGia (ID, ThoiGianBatDauApDung, ThoiGianKetThucApDung, GiaThapNhat, GiaCongBo, MaPhong)
-- VALUES 
-- ('1', '2024-01-01 00:00:00', '2024-12-31 23:59:59', 450000, 500000, 'P101'),
-- ('2', '2024-01-01 00:00:00', '2024-12-31 23:59:59', 650000, 700000, 'P102');

-- INSERT INTO CoSoVatChat(ID, TenTrangBi, GiaMua, MaSanPham, TinhTrang, MaPhong, imageURL)
-- VALUES
-- ('CS01', 'TV Samsung', 5000000, 'TV1', 'good', 'P101', 'a1.png'),
-- ('CS02', 'Tủ lạnh mini', 3000000, 'TL1', 'broken', 'P102', 'a2.jpg'),
-- ('CS01', 'Nệm Kim Đan', 6000000, 'N1', 'broken', 'P101', 'a3.png'),
-- ('CS01', 'Két sắt', 7000000, 'KS1', 'good', 'P101', 'a4.png'),
-- ('CS01', 'Quạt máy senko', 100000, 'Q1', 'broken', 'P101', 'a5.png');

-- INSERT INTO TienNghiPhong_Phong (MaPhong, MaTienNghi)
-- VALUES
-- ('P101', 'TN01'),
-- ('P102', 'TN02');

-- INSERT INTO DonDatPhong (MaDon, IDLeTan, IDKhachHang, ThoiGianDat, TrangThaiDon, NgayNhanPhong, NgayTraPhong, Nguon, SoTienDatCoc)
-- VALUES
-- ('DDP01', 'NV03', 'KH01', '2024-11-20 10:00:00', 'confirmed', '2024-12-01', '2024-12-01', 'Website', 100000),
-- ('DDP02', 'NV03', 'KH02', '2024-11-22 14:30:00', 'not confirmed', '2024-12-01', '2024-12-05', 'App', 200000);

-- INSERT INTO BanGhiPhong (MaPhong, ThoiGianTaoBanGhiPhong, MaDatPhong, IDBanBaoCao, GiaTien)
-- VALUES
-- ('P102', '2024-12-01 10:30:00', 'DDP01', 'BBP01', 500000),
-- ('P103', '2024-12-01 10:30:00', 'DDP01', 'BBP01', 1000000),
-- ('P104', '2024-12-01 15:00:00', 'DDP02', 'BBP02', 800000);


-- INSERT INTO DonDatDichVuAnUong (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, SoLuong, TongTien, TrangThai)
-- VALUES
-- ('DVAU01', 'AU01', 'P102', '2024-12-01 10:30:00', '2024-12-05 12:00:00', 2, 500.00, 'completed'),
-- ('DVAU02', 'AU02', 'P104', '2024-12-01 15:00:00', '2024-12-05 18:00:00', 3, 750.00, 'not completed');

-- INSERT INTO DonSuDungDichVuGiatUi (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, SoKg, TongTien, TrangThai)
-- VALUES
-- ('DVGU01', 'GU01', 'P102', '2024-12-01 10:30:00', '2024-12-01 16:00:00', 5.5, 275.00, 'completed'),
-- ('DVGU02', 'GU02', 'P104', '2024-12-01 15:00:00', '2024-12-01 20:00:00', 3.2, 160.00, 'not completed');

-- INSERT INTO DonSuDungDichVuDuaDon (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, DiemDi, DiemDen, TongTien, TrangThai)
-- VALUES
-- ('DVDD01', 'DD01', 'P102', '2024-12-01 10:30:00', '2024-12-01 09:00:00', 'BKCS1', 'Khách sạn chi nhánh Điện Biên Phủ', 120.00, 'completed'),
-- ('DVDD02', 'DD02', 'P104', '2024-12-01 15:00:00', '2024-12-01 19:00:00', 'BKCS2', 'Khách sạn chi nhánh Bà Huyện Thanh Quan', 180.00, 'not completed');

-- INSERT INTO DonSuDungDichVuPhongHop (MaDon, MaDichVu, MaPhong, ThoiGianTaoBanGhiPhong, ThoiGian, ThoiGianBatDau, ThoiGianKetThuc, TongTien, TrangThai)
-- VALUES
-- ('DVP01', 'PH01', 'P102', '2024-12-01 10:30:00', '2024-12-01 14:00:00', '2024-12-01 14:00:00', '2024-12-01 16:00:00', 400.00, 'completed'),
-- ('DVP02', 'PH02', 'P104', '2024-12-01 15:00:00', '2024-12-01 09:00:00', '2024-12-01 09:00:00', '2024-12-01 12:00:00', 300.00, 'not completed');

-- INSERT INTO DoiTuongGiamGia (ID, MaGiamGia)
-- VALUES
-- ('DTGG01', 'GG01'),
-- ('DTGG02', 'GG02');


-- INSERT INTO DichVuPhong (MaDichVu, MucGia, MoTa, IDGiamGia)
-- VALUES
-- ('DVPH01', 150000, 'xịn', 'DTGG01'),
-- ('DVPH02', 100000, 'vừa vừa', 'DTGG02');


-- INSERT INTO HoaDon (MaHoaDon, ThoiGianXuatHoaDon, IDKhachHang, MaDon)
-- VALUES
-- ('HD01', '2024-12-01 18:00:00', 'KH01', 'DDP01'),
-- ('HD02', '2024-12-01 12:00:00', 'KH02', 'DDP02');

-- INSERT INTO vatphamsudung (ID, SoLuong, Gia, MaBanBaoCaoPhong)
-- VALUES
-- ('VP01', 3, 30000, 'BBP01'),
-- ('VP02', 2, 45000, 'BBP02');






