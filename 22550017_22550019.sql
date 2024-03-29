/*
Họ và tên: Đào Nhâm Phúc
MSSV: 22550017
Họ và tên: Phạm Hoàng Sang
MSSV: 22550019
*/

-- Tạo cơ sở dữ liệu quản lý phòng trọ
CREATE DATABASE QLPT

USE QLPT

/* Chuyển về định dạng ngày - tháng - năm */
SET DATEFORMAT DMY

--Tạo bảng khách hàng
CREATE TABLE KHACHHANG
(
	MAKH CHAR(4) NOT NULL PRIMARY KEY,
	TENKH NVARCHAR(40),
	CMND_CCCD VARCHAR(20),
	NGSINH DATE,
	GIOITINH NVARCHAR(5),
	SDT VARCHAR(20),
	DCHI NVARCHAR(200),
	NGNGHIEP NVARCHAR(40)
)
--Tạo bảng phòng trọ
CREATE TABLE PHONGTRO
(
	MAPT CHAR(5) NOT NULL PRIMARY KEY,
	TENPT NVARCHAR(20),
	TINHTRANG NVARCHAR(20),
	DCHIPT NVARCHAR(20),
	GIA MONEY
)
--Tạo bảng thiết bị
CREATE TABLE THIETBI
(
	MATB CHAR(5) NOT NULL PRIMARY KEY,
	TENTB NVARCHAR(20)
)
--Tạo bảng phòng trọ trang bị thiết bị
CREATE TABLE PHONGTRO_TBTB
(
	MAPT CHAR(5) NOT NULL FOREIGN KEY REFERENCES PHONGTRO(MAPT),
	MATB CHAR(5) NOT NULL FOREIGN KEY REFERENCES THIETBI(MATB),
	SL INT
	PRIMARY KEY (MAPT, MATB)
)
--Tạo bảng dịch vụ
CREATE TABLE DICHVU
(
	MADV CHAR(6) NOT NULL PRIMARY KEY,
	TENDV NVARCHAR(20)
)
--Tạo bảng phiếu đăng ký
CREATE TABLE PHIEUDK
(
	MAPDK CHAR(6) NOT NULL PRIMARY KEY,
	MAKH CHAR(4) NOT NULL FOREIGN KEY REFERENCES KHACHHANG(MAKH),
	MAPT CHAR(5) NOT NULL FOREIGN KEY REFERENCES PHONGTRO(MAPT),
	NGTHUE DATE,
	NGTRA DATE
)
--Tạo bảng chi tiết dịch vụ
CREATE TABLE CTDV
(
	MAPDK CHAR(6) NOT NULL FOREIGN KEY REFERENCES PHIEUDK(MAPDK),
	MADV CHAR(6) NOT NULL FOREIGN KEY REFERENCES DICHVU(MADV),
	TUNGAY DATE,
	DENNGAY DATE,
	SC FLOAT,
	SM FLOAT,
	DONGIA MONEY
	/*PRIMARY KEY (MAPDK, MADV)*/
)
--Tạo bảng hóa đơn
CREATE TABLE PHIEUTHANHTOAN
(
	MAPTT CHAR(5) NOT NULL PRIMARY KEY,
	MAPDK CHAR(6) NOT NULL FOREIGN KEY REFERENCES PHIEUDK(MAPDK),
	NGTT DATE,
	SOTHANG INT,
	TONGTIEN MONEY
)

--Tạo thêm các ràng buộc nếu có
/* Ràng buộc tồn tại duy nhất */
-- Chứng minh nhân dân hoặc căn cước công dân (CMND_CCCD) của mỗi khách hàng là duy nhất” cho quan hệ KHACHHANG
ALTER TABLE KHACHHANG ADD CONSTRAINT UQ_KHACHHANG_CMND_CCCD UNIQUE (CMND_CCCD)

/* Ràng buộc kiểm tra điều kiện */
-- Giới tính (GIOITINH) của khách hàng phải là Nam hoặc Nữ
ALTER TABLE KHACHHANG ADD CONSTRAINT CK_KHACHHANG_GIOITINH CHECK (GIOITINH IN ('Nam', N'Nữ'))

INSERT INTO KHACHHANG (MAKH, GIOITINH) VALUES ('KH01', N'Ba')
INSERT INTO KHACHHANG (MAKH, GIOITINH) VALUES ('KH01', N'Nữ')

-- Giá (GIA) phòng trọ phải lớn hơn hoặc bằng 0
ALTER TABLE PHONGTRO ADD CONSTRAINT CK_PHONGTRO_GIA CHECK (GIA >= 0)

-- Tình trạng phòng trọ (TINHTRANG) chỉ được là 'Đã ở', 'Còn trống' và 'Đang sửa chữa'
ALTER TABLE PHONGTRO ADD CONSTRAINT CK_PHONGTRO_TINHTRANG CHECK (TINHTRANG IN (N'Đã ở', N'Còn trống', N'Đang sửa chữa'))

INSERT INTO PHONGTRO (MAPT, GIA, TINHTRANG) VALUES ('PT01', -2, N'Còn trống')
INSERT INTO PHONGTRO (MAPT, GIA, TINHTRANG) VALUES ('PT01', 1000000, N'Không cho thuê')
INSERT INTO PHONGTRO (MAPT, GIA, TINHTRANG) VALUES ('PT01', 1000000, N'Còn trống')
-- Số lượng (SL) thiết bị phải lớn hơn hoặc bằng 0
ALTER TABLE PHONGTRO_TBTB ADD CONSTRAINT CK_PHONGTRO_TBTB_SL CHECK (SL >= 0)

INSERT INTO THIETBI(MATB, TENTB) VALUES ('TB01', N'Tủ Lạnh')

INSERT INTO PHONGTRO_TBTB (MAPT, MATB, SL) VALUES ('PT01', 'TB01', -5)
INSERT INTO PHONGTRO_TBTB (MAPT, MATB, SL) VALUES ('PT01', 'TB01', 2)
-- Ngày trả (NGTRA) phải lớn hơn hoặc bằng ngày thuê (NGTHUE) trong bảng phiếu đăng ký
ALTER TABLE PHIEUDK ADD CONSTRAINT CK_PHIEUDK_NGTRA_NGTHUE CHECK (NGTRA >= NGTHUE)

INSERT INTO PHIEUDK (MAPDK, MAKH, MAPT, NGTRA, NGTHUE) VALUES ('PDK01', 'KH01', 'PT01', '10/10/2022', '20/10/2022')
INSERT INTO PHIEUDK (MAPDK, MAKH, MAPT, NGTRA, NGTHUE) VALUES ('PDK01', 'KH01', 'PT01', '10/10/2022', '08/10/2022')
/* Số cũ (SC) và số mới (SM) trong bảng chi tiết dịch vụ phải lớn hơn hoặc bằng 0
   Số mới (SM) trong bảng chi tiết dịch vụ phải lớn hơn số cũ (SC) */
ALTER TABLE CTDV ADD CONSTRAINT CK_CTDV_SC CHECK (SC >= 0)
ALTER TABLE CTDV ADD CONSTRAINT CK_CTDV_SM CHECK (SM >= 0)
ALTER TABLE CTDV ADD CONSTRAINT CK_CTDV_SM_SC CHECK (SM >= SC)

INSERT INTO DICHVU (MADV, TENDV) VALUES ('DV01', N'Điện')
INSERT INTO DICHVU (MADV, TENDV) VALUES ('DV02', N'Nước')

INSERT INTO CTDV (MAPDK, MADV, SC) VALUES ('PDK01', 'DV01',  -2)
INSERT INTO CTDV (MAPDK, MADV, SM) VALUES ('PDK01', 'DV01',  -10)
INSERT INTO CTDV (MAPDK, MADV, SC, SM) VALUES ('PDK01', 'DV01',  -2, -10)

INSERT INTO CTDV (MAPDK, MADV, SC) VALUES ('PDK01', 'DV01', 100) 
INSERT INTO CTDV (MAPDK, MADV, SM) VALUES ('PDK01', 'DV01', 200) 
INSERT INTO CTDV (MAPDK, MADV, SC, SM) VALUES ('PDK01', 'DV01',  100, 90)
INSERT INTO CTDV (MAPDK, MADV, SC, SM) VALUES ('PDK01', 'DV01', 100, 200) 

-- Đến ngày (DENNGAY) phải lớn hơn hoặc bằng từ ngày (TUNGAY) trong bảng chi tiết dịch vụ
ALTER TABLE CTDV ADD CONSTRAINT CK_CTDV_DENNGAY_TUNGAY CHECK (DENNGAY >= TUNGAY)

INSERT INTO CTDV (MAPDK, MADV, TUNGAY, DENNGAY) VALUES ('PDK01', 'DV01', '20/12/2022', '18/12/2022')
INSERT INTO CTDV (MAPDK, MADV, TUNGAY, DENNGAY) VALUES ('PDK01', 'DV01', '20/12/2022', '30/12/2022')
-- Đơn giá (DONGIA) trong bảng chi tiết dịch vụ phải lớn hơn hoặc bằng 0
ALTER TABLE CTDV ADD CONSTRAINT CK_CTDV_DONGIA CHECK (DONGIA >= 0)

INSERT INTO CTDV (MAPDK, MADV, DONGIA) VALUES ('PDK01', 'DV01', -3000)
INSERT INTO CTDV (MAPDK, MADV, DONGIA) VALUES ('PDK01', 'DV01', 3000)
-- Số tháng (SOTHANG) trong bảng phiếu thanh toán phải bé lớn hoặc bằng 1 và bé hơn hoặc bằng 12
ALTER TABLE PHIEUTHANHTOAN ADD CONSTRAINT CK_CTDV_SOTHANG CHECK (SOTHANG >= 1 AND SOTHANG <= 12)

INSERT INTO PHIEUTHANHTOAN (MAPTT, MAPDK, SOTHANG) VALUES ('PTT01', 'PDK01', 13)
INSERT INTO PHIEUTHANHTOAN (MAPTT, MAPDK, SOTHANG) VALUES ('PTT01', 'PDK01', 1)
-- Tổng tiền (TONGTIEN) trong bảng phiếu thanh toán phải lớn hơn hoặc bằng 0
ALTER TABLE PHIEUTHANHTOAN ADD CONSTRAINT CK_CTDV_TONGTIEN CHECK (TONGTIEN >0)

INSERT INTO PHIEUTHANHTOAN (MAPTT, MAPDK, TONGTIEN) VALUES ('PTT02', 'PDK01', -1000000)
INSERT INTO PHIEUTHANHTOAN (MAPTT, MAPDK, TONGTIEN) VALUES ('PTT02', 'PDK01', 1000000)


/*Stored procedure*/
-- In ra danh sách khách hàng với đầy đủ các thuộc tính có trong bảng KHACHHANG. 

GO
CREATE PROC DS_KHACHHANG
AS
BEGIN
	SELECT *
	FROM KHACHHANG
END
GO

EXEC DS_KHACHHANG

-- In ra danh sách dịch vụ với đầy đủ các thuộc tính có trong bảng DICHVU. 

GO
CREATE PROC DS_DICHVU
AS
BEGIN
	SELECT *
	FROM DICHVU
END
GO

EXEC DS_DICHVU

-- In ra danh sách dịch vụ với đầy đủ các thuộc tính có trong bảng DICHVU. 

GO
CREATE PROC DS_PHONGTRO
AS
BEGIN
	SELECT *
	FROM PHONGTRO
END
GO

EXEC DS_PHONGTRO

-- In ra danh sách dịch vụ với đầy đủ các thuộc tính có trong bảng DICHVU. 

GO
CREATE PROC DS_THIETBI
AS
BEGIN
	SELECT *
	FROM THIETBI
END
GO

EXEC DS_THIETBI

-- In ra danh sách thông tin các phòng trọ còn trống và đang sửa chữa

GO
CREATE PROC DS_PTRO_NULL
AS
BEGIN
	SELECT *
	FROM PHONGTRO 
	WHERE TINHTRANG = N'Còn trống' OR  TINHTRANG = N'Đang sửa chữa'
END
GO

EXEC DS_PTRO_NULL

-- In ra danh sách thông tin các phòng trọ có người ở

GO
CREATE PROC DS_PTRO_NOT_NULL
AS
BEGIN
	SELECT *
	FROM PHONGTRO 
	WHERE TINHTRANG NOT IN (N'Còn trống', N'Đang sửa chữa')
END
GO

EXEC DS_PTRO_NOT_NULL

-- In ra danh sách thông tin khách hàng (MAKH, TENKH) hiện đang thuê trọ

GO
CREATE PROC DS_KH_DANGTHUE_PTRO
AS
BEGIN
	SELECT DISTINCT(KH.MAKH), TENKH
	FROM KHACHHANG KH, PHIEUDK PDK
	WHERE KH.MAKH = PDK.MAKH AND NGTRA IS NULL
END
GO

EXEC DS_KH_DANGTHUE_PTRO

-- In ra danh sách thông tin khách hàng (MAKH, TENKH) đã trả phòng trọ 

GO
CREATE PROC DS_KH_DATRA_PTRO
AS
BEGIN
	SELECT DISTINCT(KH.MAKH), TENKH
	FROM KHACHHANG KH, PHIEUDK PDK
	WHERE KH.MAKH = PDK.MAKH AND NGTRA IS NOT NULL
END
GO

EXEC DS_KH_DATRA_PTRO

/* Stored procedure với tham số vào: */
/*
Tham số đưa vào: MAPT
Yêu cầu: In ra thông tin tình trạng phong trọ như thế nào
Thực thi với các trường hợp tham số:
• ‘PT01’.
• ‘PT02’.
• ‘PT10’.
*/
GO
CREATE PROC TINHTRANG_PTRO_MAPT @MAPT CHAR(5)
AS
BEGIN
	SELECT MAPT, TENPT, TINHTRANG
	FROM PHONGTRO
	WHERE MAPT = @MAPT
END
GO

EXEC TINHTRANG_PTRO_MAPT 'PT01'
EXEC TINHTRANG_PTRO_MAPT 'PT02'
EXEC TINHTRANG_PTRO_MAPT 'PT10'

/*
Tham số đưa vào: MAPT
Yêu cầu: In ra thông tin của phong trọ đó
Thực thi với các trường hợp tham số:
• ‘PT01’.
• ‘PT02’.
• ‘PT03’.
*/
GO
CREATE PROC THONGTIN_PTRO_MAPT @MAPT CHAR(5)
AS
BEGIN
	SELECT *
	FROM PHONGTRO
	WHERE MAPT = @MAPT
END
GO

EXEC THONGTIN_PTRO_MAPT 'PT01'
EXEC THONGTIN_PTRO_MAPT 'PT02'
EXEC THONGTIN_PTRO_MAPT 'PT03'

/*
Tham số đưa vào: MAKH
Yêu cầu: In ra thông tin của khách hàng đó
Thực thi với các trường hợp tham số:
• ‘KH02’.
• ‘KH03’.
• ‘KH04’.
*/
GO
CREATE PROC THONGTIN_KH_MAKH @MAKH CHAR(4)
AS
BEGIN
	SELECT *
	FROM KHACHHANG
	WHERE MAKH = @MAKH
END
GO

EXEC THONGTIN_KH_MAKH 'KH02'
EXEC THONGTIN_KH_MAKH 'KH03'
EXEC THONGTIN_KH_MAKH 'KH04'


/*
Tham số đưa vào: MAKH
Yêu cầu: In ra thông tin phòng trọ và các dịch vụ đã đăng ký sử dụng của phòng trọ đứng tên khách hàng
Thực thi với các trường hợp tham số:
• ‘KH01’.
• ‘KH02’.
• ‘KH06’.
*/
GO
CREATE PROC THONGTIN_PTRO_DV_MAKH @MAKH CHAR(4)
AS
BEGIN
	SELECT DISTINCT(PT.MAPT), TENPT, TENDV
	FROM KHACHHANG KH, PHONGTRO PT, PHIEUDK PDK, DICHVU DV, CTDV CT
	WHERE KH.MAKH = PDK.MAKH AND PT.MAPT = PDK.MAPT AND DV.MADV = CT.MADV AND PDK.MAPDK =CT.MAPDK AND KH.MAKH = @MAKH
END
GO

EXEC THONGTIN_PTRO_DV_MAKH 'KH02'
EXEC THONGTIN_PTRO_DV_MAKH 'KH09'
EXEC THONGTIN_PTRO_DV_MAKH 'KH10'

/* Stored procedure với nhiều tham số vào: */
/* Tham số đưa vào: MAKH, TENKH, CMND_CCCD, NGSINH, GIOITINH, SDT, DCHI, NGNGHIEP
Yêu cầu: Thêm dữ liệu mới vào bảng KHACHHANG với các thông tin được đưa vào. 
Trước khi thêm dữ liệu, cần kiểm tra MAKH trong bảng KHACHHANG có trùng không, 
nếu trùng thì thông báo 'Mã khách hàng bị trùng' và trả về giá trị 0, 
ngược lại thì thêm dữ liệu mới, thông báo 'Thêm dữ liệu thành công' và trả về giá trị 1. 
Thực thi với các trường hợp tham số:  
• KH10, N'Trần Thị Bưởi', '555444777', '16/09/1969', N'Nữ', '0912333444', N'Lâm Đồng', N'Văn phòng')
• KH11, N'Trần Thị Bưởi', '555444777','16/09/1999', N'Nữ', '0912333444', N'Lâm Đồng', N'Văn phòng')
• KH12, N'Lê Minh Tấn', '364789521', '20/07/1995', N'Nam', '0979111444', N'Khánh Hòa', N'Công nhân')
*/
GO
CREATE PROC ADD_KHACHHANG @MAKH CHAR(4), @TENKH NVARCHAR(40), @CMND_CCCD VARCHAR(20), @NGSINH DATE, 
							@GIOITINH NVARCHAR(5), @SDT VARCHAR(20), @DCHI NVARCHAR(200), @NGNGHIEP NVARCHAR(40)
AS
	IF EXISTS (SELECT * FROM KHACHHANG WHERE MAKH = @MAKH)
		BEGIN
			PRINT N'Mã khách hàng bị trùng'
			RETURN 0
		END
	ELSE
		BEGIN
			INSERT INTO KHACHHANG (MAKH, TENKH, CMND_CCCD, NGSINH, GIOITINH, SDT, DCHI, NGNGHIEP) 
			VALUES (@MAKH, @TENKH, @CMND_CCCD, @NGSINH, @GIOITINH, @SDT, @DCHI, @NGNGHIEP)
			PRINT N'Thêm dữ liệu thành công'
			RETURN 1
		END
GO
EXEC ADD_KHACHHANG @MAKH = 'KH10', @TENKH = N'Trần Thị Bưởi', @CMND_CCCD = '555444777', @NGSINH = '16/09/1969', 
					@GIOITINH = N'Nữ', @SDT = '0912333444', @DCHI = N'Lâm Đồng', @NGNGHIEP = N'Văn phòng'
EXEC ADD_KHACHHANG @MAKH = 'KH11', @TENKH = N'Trần Thị Bưởi', @CMND_CCCD = '555444777', @NGSINH = '16/09/1969', 
					@GIOITINH = N'Nữ', @SDT = '0912333444', @DCHI = N'Lâm Đồng', @NGNGHIEP = N'Văn phòng'
EXEC ADD_KHACHHANG @MAKH = 'KH12', @TENKH = N'Lê Minh Tấn', @CMND_CCCD = '364789521', @NGSINH = '20/07/1995', 
					@GIOITINH = N'Nam', @SDT = '0979111444', @DCHI = N'Khánh Hòa', @NGNGHIEP = N'Công nhân'


/* Tham số đưa vào: MAPDK, MAKH, MAPT, NGTHUE
Yêu cầu: Thêm dữ liệu mới vào bảng PHIEUDK với các thông tin được đưa vào. 
Trước khi thêm dữ liệu:
+ Cần kiểm tra MAPDK trong bảng PHIEUDK có trùng không, 
nếu trùng thì thông báo 'Mã phiếu đăng ký bị trùng' và trả về giá trị 0, ngược lại thì 
+ Cần kiểm tra MAKH đã tồn tại trong bảng KHACHHANG chưa, nếu chưa thì thông báo 'Không tìm thấy mã khách hàng' 
và trả về giá trị 0, ngược lại thì
+ Cần kiểm tra MAPT đã tồn tại trong bảng PHONGTRO chưa, nếu chưa thì thông báo 'Không tìm thấy phòng trọ' 
và trả về giá trị 0, ngược lại thì
+ Cần kiểm tra TINHTRANG trong bảng phòng trọ (PHONGTRO) nếu phòng trọ đó hiện đang 'Đã ở' hoặc 'Đang sửa chữa' 
thì thông báo 'Hiện tại phòng trọ này đang ở hoặc đang sửa chữa' và trả về giá trị 0, ngược lại thì thêm dữ liệu mới và
	- Cập nhật tình trạng phòng trọ (TINHTRANG) thành 'Đã ở'
	- Và thông báo 'Thêm dữ liệu thành công' và trả về giá trị 1.  
+ Thực thi với các trường hợp tham số: 
• 'PDK10', 'KH12', 'PT04', '16/10/2022' 
• 'PDK11', 'KH13', 'PT04', '16/10/2022'
• 'PDK11', 'KH12', 'PT11', '16/10/2022'
• 'PDK11', 'KH12', 'PT04', '16/10/2022'
*/
GO
CREATE PROC ADD_PHIEUDK @MAPDK CHAR(6), @MAKH CHAR(4), @MAPT CHAR(5), @NGTHUE DATE
AS
BEGIN
	DECLARE @TINHTRANG NVARCHAR(20)
	SELECT @TINHTRANG = TINHTRANG 
	FROM PHONGTRO
	WHERE MAPT = @MAPT

	IF EXISTS (SELECT * FROM PHIEUDK WHERE MAPDK = @MAPDK)
		BEGIN
			PRINT N'Mã phiếu đăng ký bị trùng'
			RETURN 0
		END
	ELSE IF NOT EXISTS (SELECT * 
						FROM KHACHHANG 
						WHERE MAKH = @MAKH)
		BEGIN
			PRINT N'Không tìm thấy mã khách hàng'
			RETURN 0
		END
	ELSE IF NOT EXISTS (SELECT * 
						FROM PHONGTRO 
						WHERE MAPT = @MAPT)
		BEGIN
			PRINT N'Không tìm thấy mã phòng trọ'
			RETURN 0
		END
	ELSE IF (@TINHTRANG IN (N'Đã ở', N'Đang sửa chữa'))
		BEGIN
			PRINT CONCAT(N'Hiện tại phòng trọ: ' , @TINHTRANG)
			RETURN 0
		END
	ELSE
		BEGIN
			INSERT INTO PHIEUDK (MAPDK, MAKH, MAPT, NGTHUE) VALUES (@MAPDK, @MAKH, @MAPT, @NGTHUE)

			UPDATE PHONGTRO SET TINHTRANG = N'Đã ở' WHERE MAPT = @MAPT

			PRINT N'Thêm dữ liệu thành công'
			RETURN 1
		END
END

GO
EXEC ADD_PHIEUDK @MAPDK = 'PDK10', @MAKH = 'KH12',  @MAPT = 'PT04', @NGTHUE = '16/10/2022'
EXEC ADD_PHIEUDK @MAPDK = 'PDK11', @MAKH = 'KH13',  @MAPT = 'PT04', @NGTHUE = '16/10/2022'
EXEC ADD_PHIEUDK @MAPDK = 'PDK11', @MAKH = 'KH12',  @MAPT = 'PT11', @NGTHUE = '16/10/2022'
EXEC ADD_PHIEUDK @MAPDK = 'PDK11', @MAKH = 'KH12',  @MAPT = 'PT04', @NGTHUE = '16/10/2022'


/*Tham số đưa vào: TENPT. 
Tham số trả ra: GIA. 
Yêu cầu: Đưa vào tên phòng trọ (TENPT), trả ra giá tiền (GIA) của phòng trọ đó, 
nếu không tìm thấy phòng trọ tương ứng thì thông báo 'Không tìm thấy phòng trọ' và trả về giá trị 0. 
Thực thi với các trường hợp tham số: 
• 'A05'. 
• 'A08'. 
• 'A11'. 
*/
GO
CREATE PROC GIA_PHONGTRO @TENPT NVARCHAR(20), @GIA MONEY OUTPUT
AS
	IF NOT EXISTS (SELECT * 
					FROM PHONGTRO 
					WHERE TENPT = @TENPT)
		BEGIN
			PRINT N'Không tìm thấy phòng trọ'
			RETURN 0
		END
	ELSE
		BEGIN
			SELECT @GIA = GIA 
			FROM PHONGTRO 
			WHERE TENPT = @TENPT
		END
GO

DECLARE @GIA MONEY
EXEC GIA_PHONGTRO 'A05', @GIA OUT
PRINT @GIA
GO
DECLARE @GIA MONEY
EXEC GIA_PHONGTRO 'A08', @GIA OUT
PRINT @GIA
GO
DECLARE @GIA MONEY
EXEC GIA_PHONGTRO 'A11', @GIA OUT
PRINT @GIA
GO

/* Xây dựng Function */
/* Hàm in ra tất cả thông tin của khách hàng có mã số khách hàng 
(MAKH) được truyền vào. 
Thực thi với các trường hợp: 
• Truyền vào MAKH = ‘KH02’. 
• Truyền vào MAKH = ‘KH08’. 
• Truyền vào MAKH = ‘KH09’. 

*/
GO
CREATE FUNCTION F_TTKH_MAKH (@MAKH CHAR(4))
RETURNS TABLE
AS
	RETURN (SELECT *
			FROM KHACHHANG
			WHERE MAKH = @MAKH)
GO
SELECT * FROM DBO.F_TTKH_MAKH('KH02')
SELECT * FROM DBO.F_TTKH_MAKH('KH08')
SELECT * FROM DBO.F_TTKH_MAKH('KH09')


/* Hàm in ra tất cả thông tin của phòng trọ có mã số phòng trọ
(MAPT) được truyền vào. 
Thực thi với các trường hợp: 
• Truyền vào MAPT = ‘PT03’. 
• Truyền vào MAPT = ‘PT05’. 
• Truyền vào MAPT = ‘PT07’. 

*/
GO
CREATE FUNCTION F_TTPT_MAPT (@MAPT CHAR(5))
RETURNS TABLE
AS
	RETURN (SELECT *
			FROM PHONGTRO
			WHERE MAPT = @MAPT)
GO
SELECT * FROM DBO.F_TTPT_MAPT('PT03')
SELECT * FROM DBO.F_TTPT_MAPT('PT05')
SELECT * FROM DBO.F_TTPT_MAPT('PT07')

/* Hàm in ra danh sách các phòng trọ với tất cả thông tin có tình trạng (TINHTRANG) được truyền vào. 
Thực thi với các trường hợp:
• Truyền vào TINHTRANG = ‘Đã ở’. 
• Truyền vào TINHTRANG = ‘Còn trống’. 
• Truyền vào TINHTRANG = ‘Đang sửa chữa’. 
*/
GO
CREATE FUNCTION F_DSPT_TINHTRANG (@TINHTRANG NVARCHAR(20))
RETURNS TABLE
AS
	RETURN (SELECT *
			FROM PHONGTRO
			WHERE TINHTRANG = @TINHTRANG)
GO
SELECT * FROM DBO.F_DSPT_TINHTRANG(N'Đã ở')
SELECT * FROM DBO.F_DSPT_TINHTRANG(N'Còn trống')
SELECT * FROM DBO.F_DSPT_TINHTRANG(N'Đang sửa chữa')


/* Hàm đếm số lượng phòng trọ có giá lớn hơn hoặc bằng mức giá (GIA) được truyền vào. 
Nếu không tìm thấy giá tương ứng thì trả về giá trị 0.
Thực thi với các trường hợp: 
• Truyền vào GIA = 2500000. 
• Truyền vào GIA = 3000000. 
• Truyền vào GIA = 3500000.
*/
GO
CREATE FUNCTION F_SLPT_GIA_LONHON_HOACBANG (@GIA MONEY)
RETURNS INT
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM PHONGTRO WHERE GIA >= @GIA)
		RETURN 0
	RETURN (SELECT COUNT(MAPT) 
			FROM PHONGTRO 
			WHERE GIA >= @GIA)
END
GO

SELECT DBO.F_SLPT_GIA_LONHON_HOACBANG(2500000) SLPHONGTRO
SELECT DBO.F_SLPT_GIA_LONHON_HOACBANG(3000000) SLPHONGTRO
SELECT DBO.F_SLPT_GIA_LONHON_HOACBANG(4000000) SLPHONGTRO


/* Viết hàm in ra danh sách khách hàng đang thuê trọ */
GO
CREATE FUNCTION F_DSKH_DANGTHUE ()
RETURNS TABLE
AS
	RETURN (SELECT DISTINCT(KH.MAKH), TENKH
			FROM KHACHHANG KH, PHIEUDK PDK
			WHERE KH.MAKH = PDK.MAKH AND NGTRA IS NULL)
GO

SELECT * FROM DBO.F_DSKH_DANGTHUE()
/* Xây dựng Trigger */
/* Tạo Trigger cho ràng buộc: Khi thêm một khách hàng mới thành công thì hiển thị
thông báo ‘Thêm khách hàng thành công’.
Kiểm tra Trigger: Thêm khách hàng có MAKH = ‘KH00’*/
GO
CREATE TRIGGER TR_TKH
ON KHACHHANG
FOR INSERT 
AS
	PRINT N'Thêm khách hàng thành công'
GO
INSERT INTO KHACHHANG (MAKH,TENKH,CMND_CCCD) VALUES ('KH00','Nguyen Van B','111111111')
GO
/*Tạo Trigger cho ràng buộc: Khi chỉnh sửa giá (GIA) của một phòng 
thì cho biết tình trạng của phòng đó (TINHTRANG)
Kiểm tra Trigger: Sửa GIA của phong có MAPT = ‘PT09’ thành ‘9999999’.*/
GO
CREATE TRIGGER TR_UPGIA
ON PHONGTRO
FOR UPDATE
AS 
	BEGIN
		DECLARE @TINHTRANG NVARCHAR(20)
		SELECT @TINHTRANG = TINHTRANG
		FROM INSERTED
		PRINT N'Tình trạng phòng vừa cập nhật là '+ @TINHTRANG
	END
UPDATE PHONGTRO SET GIA = '9999999' WHERE MAPT = 'PT09'
/* Tạo Trigger cho ràng buộc: Tình trạng của phòng trọ chỉ có thể là ‘Còn trống’, ‘Đã ở’, ‘Đang sửa chữa’,
Kiểm tra Trigger:
• Thêm dữ liệu mới:
• Thêm phòng mới có các thuộc tính như sau: (MAPT, TINHTRANG) = (‘PT98’, N‘Đã ở’).
• Thêm phòng mới có các thuộc tính như sau: (MAPT, TINHTRANG) = (‘PT99’, N‘Không được ở’).
• Sửa dữ liệu đã có:
• Cập nhật TINHTRANG = ‘Đang sửa chữa’ cho phòng có MAPT = ‘PT05’.
• Cập nhật TINHTRANG = ‘Hết phòng’ cho phòng có MAPT = ‘PT06’.*/
CREATE TRIGGER TR_TTP
ON PHONGTRO
INSTEAD OF INSERT 
AS
	BEGIN
		DECLARE @TINHTRANG_NEW NVARCHAR(20)
		SELECT @TINHTRANG_NEW = TINHTRANG
		FROM INSERTED
		IF @TINHTRANG_NEW IN (N'Còn trống',N'Đã ở', N'Đang sửa chữa')
			BEGIN
				DECLARE @MAPT CHAR(5), @TENPT NVARCHAR(20), @TINHTRANG NVARCHAR(20), @DCHIPT NVARCHAR(20), @GIA MONEY 
				SELECT @MAPT=MAPT, @TENPT=TENPT, @TINHTRANG=TINHTRANG, @DCHIPT=DCHIPT, @GIA=GIA
				FROM inserted
				INSERT INTO PHONGTRO (MAPT, TINHTRANG) VALUES (@MAPT, @TINHTRANG)
				PRINT N'Phòng đã được thêm thành công'
			END
		ELSE
			PRINT N'Tình trạng phòng bắt buộc là Còn trống, Đã ở, Đang sửa chữa'
	END
INSERT INTO PHONGTRO (MAPT, TINHTRANG) VALUES ('PT98',N'Đã ở')
INSERT INTO PHONGTRO (MAPT, TINHTRANG) VALUES ('PT99',N'Không được ở')
--update
CREATE TRIGGER TR_UPTTP
ON PHONGTRO
INSTEAD OF UPDATE
AS
	BEGIN
		DECLARE @TINHTRANG_NEW NVARCHAR(20)
		SELECT @TINHTRANG_NEW = TINHTRANG
		FROM INSERTED
		IF @TINHTRANG_NEW IN (N'Còn trống',N'Đã ở', N'Đang sửa chữa')
			BEGIN
				DECLARE @MAPT CHAR(5), @TENPT NVARCHAR(20), @TINHTRANG NVARCHAR(20), @DCHIPT NVARCHAR(20), @GIA MONEY 
				SELECT @MAPT=MAPT 
				FROM inserted
				UPDATE PHONGTRO SET TINHTRANG = @TINHTRANG_NEW WHERE MAPT = @MAPT
				PRINT N'Phòng đã được cập nhật thành công'
			END
		ELSE
			PRINT N'Tình trạng phòng bắt buộc là Còn trống, Đã ở, Đang sửa chữa'
	END
UPDATE PHONGTRO SET TINHTRANG = N'Đã ở' WHERE MAPT ='PT01'
UPDATE PHONGTRO SET TINHTRANG = N'Hết phòng' WHERE MAPT ='PT06'
/*
Tạo Trigger cho ràng buộc: Khi thêm một phiếu thanh toán mới thì hiển thị thông báo ‘Phiếu thanh toán của 
khách hàng <HOTEN> đã được thêm thành công’.
Kiểm tra Trigger:
• Thêm phiếu thanh toán mới có các thuộc tính như sau: (MAPTT, MAPDK, NGTT, SOTHANG, TONGTIEN) = ('PTT21', ‘PDK11’, '16/11/2022’, 10, 3210000).
*/
GO
CREATE TRIGGER TR_PTT
ON PHIEUTHANHTOAN
FOR INSERT 
AS
	BEGIN
		DECLARE @TENKH NVARCHAR(40)

		SELECT @TENKH = TENKH 
		FROM INSERTED I, KHACHHANG KH, PHIEUDK PDK
		WHERE I.MAPDK = PDK.MAPDK AND PDK.MAKH = KH.MAKH

		PRINT N'Phiếu thanh toán của khách hàng ' + @TENKH + N' đã được thêm thành công'
	END
GO
INSERT INTO PHIEUTHANHTOAN (MAPTT, MAPDK, NGTT, SOTHANG, TONGTIEN) VALUES ('PTT21', 'PDK11', '16/11/2022', 10, 3210000)
GO
/*
Tạo Trigger cho ràng buộc: Ngày trả (NGTRA) phải lớn 
hơn hoặc bằng ngày thuê (NGTHUE) của khách hàng đó trong phiếu đăng ký
Kiểm tra Trigger:
• Thêm dữ liệu mới:
• Thêm phiếu đăng ký mới có các thuộc tính như sau: PHIEUDK (MAPDK, MAKH, MAPT, NGTHUE, NGTRA) = ('PDK12', 'KH12', 'PT09', '16/10/2022', '10/10/2022')

• Sửa dữ liệu đã có:
• Cập nhật NGTRA = '01/10/2022' cho phiếu đăng ký có MAPDK = ‘PDK12’.
• Cập nhật NGTHUE = '01/12/2022' cho phiếu đăng ký có MAPDK = ‘PDK12’.
• Cập nhật NGTHUE = '01/02/2022', NGTRA = '01/01/2022' cho phiếu đăng ký có MAPDK = ‘PDK12’.
• Cập nhật NGTRA = '20/12/2022' cho phiếu đăng ký có MAPDK = ‘PDK12’.
• Cập nhật GTHUE = '01/12/2022' cho phiếu đăng ký có MAPDK = ‘PDK12’.
*/
--Tạo trigger thêm ngày trả và ngày đăng ký cho phiếu đăng ký
GO
CREATE TRIGGER TR_TPDK
ON PHIEUDK
INSTEAD OF INSERT
AS
	BEGIN
		DECLARE @MAPDK CHAR(6), @MAKH CHAR(4), @MAPT CHAR(5), @NGTHUE DATE, @NGTRA DATE
		SELECT @MAPDK = MAPDK, @MAKH = MAKH, @MAPT = MAPT, @NGTHUE = NGTHUE, @NGTRA = NGTRA
		FROM INSERTED

		IF(@NGTRA >= @NGTHUE)
			BEGIN
				INSERT INTO PHIEUDK (MAPDK, MAKH, MAPT, NGTHUE, NGTRA) VALUES (@MAPDK, @MAKH, @MAPT, @NGTHUE, @NGTRA)
				PRINT N'Thêm phiếu đăng ký thành công'
			END
		ELSE
			PRINT CONCAT(N'Dữ liệu khách hàng không hợp lệ: Ngày trả ' , @NGTRA , N' phải lớn hơn ngày thuê ' , @NGTHUE)
	END
GO
INSERT INTO PHIEUDK (MAPDK, MAKH, MAPT, NGTHUE, NGTRA) VALUES ('PDK12', 'KH12', 'PT09', '16/10/2022', '10/10/2022')
INSERT INTO PHIEUDK (MAPDK, MAKH, MAPT, NGTHUE, NGTRA) VALUES ('PDK12', 'KH12', 'PT09', '16/10/2022', '10/11/2022')
--Tạo trigger sửa ngày trả và ngày thuê của phiếu đăng ký
GO
CREATE TRIGGER TR_SPDK
ON PHIEUDK
INSTEAD OF UPDATE
AS
	BEGIN
		DECLARE @MAPDK CHAR(6), @MAKH CHAR(4), @MAPT CHAR(5), @NGTHUE DATE, @NGTRA DATE
		SELECT @MAPDK = MAPDK, @MAKH = MAKH, @MAPT = MAPT, @NGTHUE = NGTHUE, @NGTRA = NGTRA
		FROM INSERTED

		IF(@NGTRA >= @NGTHUE)
			BEGIN
				UPDATE PHIEUDK SET MAPDK = @MAPDK, MAKH = @MAKH, MAPT = @MAPT, NGTHUE = @NGTHUE, NGTRA = @NGTRA  WHERE MAPDK = @MAPDK
				PRINT N'Cập nhật phiếu đăng ký thành công'
			END
		ELSE
			PRINT CONCAT(N'Dữ liệu khách hàng không hợp lệ: Ngày trả ' , @NGTRA , N' phải lớn hơn ngày thuê ' , @NGTHUE)
	END
GO

UPDATE PHIEUDK SET NGTRA = '01/10/2022' WHERE MAPDK = 'PDK12'
UPDATE PHIEUDK SET NGTHUE = '01/12/2022' WHERE MAPDK = 'PDK12'
UPDATE PHIEUDK SET NGTHUE = '01/02/2022', NGTRA = '01/01/2022' WHERE MAKH = 'PDK12'
UPDATE PHIEUDK SET NGTRA = '20/12/2022' WHERE MAPDK = 'PDK12'
UPDATE PHIEUDK SET NGTHUE = '01/12/2022' WHERE MAPDK = 'PDK12'
/*
Tạo User và Phân quyền
*/
--Tạo login
CREATE LOGIN nhamphuc_qlpt
WITH PASSWORD = '22550017'

CREATE LOGIN hoangsang_qlpt
WITH PASSWORD = '22550019'

--Tạo user
CREATE USER khachhang1 FOR LOGIN nhamphuc_qlpt

CREATE USER khachhang2 FOR LOGIN hoangsang_qlpt

--Tạo role
CREATE ROLE quyen1
CREATE ROLE quyen2


--Thêm role mặc định cho các role đã tạo
EXEC sp_addrolemember quyen1, khachhang1

EXEC sp_addrolemember quyen2, khachhang2

--người dùng có thể đọc được toàn bộ dữ liệu
EXEC sp_addrolemember db_DataReader, quyen1
--toàn bộ người dùng có quyền full-access
EXEC sp_addrolemember db_Owner, quyen2
--người dùng có quyền quản lý các Windows Group và tài khoản SQL Server đăng nhập 
EXEC sp_addrolemember db_Accessadmin, quyen1
--người dùng có thể chỉnh sửa vai trò role và quản lý các bậc quản lý, phân quyền khác
EXEC sp_addrolemember db_SecurityAdmin, quyen2
--toàn bộ người dùng có quyền full-access
EXEC sp_addrolemember db_Owner, quyen1
--người dùng có quyền quản lý các Windows Group và tài khoản SQL Server đăng nhập 
EXEC sp_addrolemember db_Accessadmin, quyen2
--Cấp quyền xem và xóa cho user
GRANT SELECT, DELETE ON KHACHHANG TO khachhang1
GRANT SELECT, DELETE ON PHONGTRO TO khachhang2
--Kiểm tra
EXEC AS USER = 'khachhang1'
SELECT * FROM KHACHHANG
REVERT

EXEC AS USER = 'khachhang2'
SELECT * FROM PHONGTRO
REVERT

--Cấp quyền từ chối thêm cho user
DENY INSERT ON KHACHHANG TO khachhang1
DENY INSERT ON PHONGTRO TO khachhang1

--test deny
EXEC AS USER = 'khachhang1'
INSERT INTO KHACHHANG VALUES('KH10', N'Trần Thị Bưởi', '555444777','16/09/1969',N'Nam', '0944251321', N'Lâm Đồng', N'Văn phòng')
REVERT

--Tạo báo cáo
--In ra danh sách khách hàng
GO
CREATE VIEW V_DSKH
AS
	SELECT KH.MAKH, TENKH, CMND_CCCD, NGSINH, GIOITINH, SDT, DCHI, NGNGHIEP
	FROM KHACHHANG KH, PHIEUDK PDK
	WHERE KH.MAKH = PDK.MAKH
GO

--In ra danh sách phòng trọ
CREATE VIEW V_DSPT
AS
	SELECT *
	FROM PHONGTRO
GO
--In ra hóa đơn của tất cả phiếu thanh toán tháng 8 năm 2020
CREATE VIEW V_HD_PDK
AS
	SELECT DISTINCT(PDK.MAPDK), TENKH, TENPT, GIA, NGTT, SOTHANG, TONGTIEN
	FROM PHIEUTHANHTOAN PTT, KHACHHANG KH, PHIEUDK PDK, PHONGTRO PT, DICHVU DV, CTDV
	WHERE PTT.MAPDK = PDK.MAPDK AND PDK.MAKH = KH.MAKH 
	AND PDK.MAPT = PT.MAPT AND DV.MADV = CTDV.MADV 
	AND PDK.MAPDK = CTDV.MAPDK AND YEAR(NGTT)= '2020' AND SOTHANG = 8
GO