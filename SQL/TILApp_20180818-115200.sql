PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "fluent" ("id" BLOB NOT NULL PRIMARY KEY, "name" TEXT NOT NULL, "batch" INTEGER NOT NULL, "createdAt" REAL , "updatedAt" REAL );
INSERT INTO fluent VALUES(X'27cc628efdd64038b5819431a19b2893','User',1,1534582223.2066378592,1534582223.2066378592);
INSERT INTO fluent VALUES(X'5c200d77e7c44c62851cc2b477eb6403','Acronym',1,1534582223.2147178649,1534582223.2147178649);
INSERT INTO fluent VALUES(X'88339929cd474f359b961002c7c0de77','Category',1,1534582223.2202348709,1534582223.2202348709);
INSERT INTO fluent VALUES(X'2f5b9ee87596463d84b81579ffdb309c','AcronymCategoryPivot',1,1534582223.2276511192,1534582223.2276511192);
INSERT INTO fluent VALUES(X'c94b720e935d4f9087cafda44d619a9e','Post',1,1534582223.2329640388,1534582223.2329640388);
INSERT INTO fluent VALUES(X'cfd96a8531934efa917d60fa746d0a2e','PostResponse',1,1534582223.2384591102,1534582223.2384591102);
CREATE TABLE `User` (
	`id`	BLOB NOT NULL,
	`name`	TEXT NOT NULL,
	`username`	TEXT NOT NULL,
	`password`	TEXT NOT NULL,
	CONSTRAINT `uq:User.username` UNIQUE(`username`),
	PRIMARY KEY(`id`)
);
INSERT INTO User VALUES(X'fe34aca7c0064db1b1f6050b52c5d169','Joe Garmon','jg','jg');
INSERT INTO User VALUES(X'7b7e4d46e2c04b5ca95452f40efc69b6','Olivier Jacky','oj','oj');
INSERT INTO User VALUES(X'd9788c3e0f0146c6871b4c56ba1fa91a','Aline Dropan','ad','ad');
INSERT INTO User VALUES(X'ae3508be76464da3893a16346a1cfb8a','Alice','alice','alice');
INSERT INTO User VALUES(X'11eab3ae08504f1281ea149f2ebd41b9','Luke','luke','luke');
INSERT INTO User VALUES(X'03fa0a0d2f754f5597f4e36c550d7527','Ramon Bike','rb','rb');
CREATE TABLE `PostResponse` (
	`id`	INTEGER NOT NULL,
	`title`	TEXT NOT NULL,
	`content`	TEXT NOT NULL,
	`username`	TEXT NOT NULL,
	`postID`	INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);
CREATE TABLE `Post` (
	`id`	INTEGER NOT NULL,
	`title`	TEXT NOT NULL,
	`content`	TEXT NOT NULL,
	`userID`	BLOB NOT NULL,
	PRIMARY KEY(`id`)
);
INSERT INTO Post VALUES(1,'Joe''s first post','Blablabla and some other things.',X'fe34aca7c0064db1b1f6050b52c5d169');
INSERT INTO Post VALUES(2,'Joe''s second post','Patati patata and some other things.',X'fe34aca7c0064db1b1f6050b52c5d169');
CREATE TABLE `Category` (
	`id`	INTEGER NOT NULL,
	`name`	TEXT NOT NULL,
	`description`	TEXT,
	PRIMARY KEY(`id`)
);
INSERT INTO Category VALUES(1,'Chat','Commonly used chat talk');
INSERT INTO Category VALUES(2,'Technical','Commonly used technical talk');
INSERT INTO Category VALUES(3,'Computer','Commonly used computer science');
INSERT INTO Category VALUES(4,'Gaming',NULL);
CREATE TABLE `Acronym_Category` (
	`id`	BLOB NOT NULL,
	`acronymID`	INTEGER NOT NULL,
	`categoryID`	INTEGER NOT NULL,
	CONSTRAINT `fk:Acronym_Category.categoryID+Category.id` FOREIGN KEY(`categoryID`) REFERENCES `Category`(`id`) ON DELETE CASCADE,
	PRIMARY KEY(`id`),
	CONSTRAINT `fk:Acronym_Category.acronymID+Acronym.id` FOREIGN KEY(`acronymID`) REFERENCES `Acronym`(`id`) ON DELETE CASCADE
);
INSERT INTO Acronym_Category VALUES(X'49272d90f80b44d0844439fca3a13b8c',3,2);
INSERT INTO Acronym_Category VALUES(X'9fa0eef2eba641a498bf98fe2db47389',9,2);
INSERT INTO Acronym_Category VALUES(X'67f481b78b6846be8539c73964364ded',11,2);
INSERT INTO Acronym_Category VALUES(X'dccc94568cdb4aae9ca8dc66475b0e9b',11,3);
INSERT INTO Acronym_Category VALUES(X'aba0c0939a6c45b6ae847be48dbd694c',3,4);
CREATE TABLE `Acronym` (
	`id`	INTEGER NOT NULL,
	`short`	TEXT NOT NULL,
	`long`	TEXT NOT NULL,
	`userID`	BLOB NOT NULL,
	PRIMARY KEY(`id`),
	CONSTRAINT `fk:Acronym.userID+User.id` FOREIGN KEY(`userID`) REFERENCES `User`(`id`)
);
INSERT INTO Acronym VALUES(3,'DIY','Done it.',X'fe34aca7c0064db1b1f6050b52c5d169');
INSERT INTO Acronym VALUES(4,'SYS','See You Soon',X'fe34aca7c0064db1b1f6050b52c5d169');
INSERT INTO Acronym VALUES(6,'LOL','Laughing Out Loud',X'fe34aca7c0064db1b1f6050b52c5d169');
INSERT INTO Acronym VALUES(7,'GNU','GNU is Not Unix',X'7b7e4d46e2c04b5ca95452f40efc69b6');
INSERT INTO Acronym VALUES(8,'IKR','I Know Right',X'fe34aca7c0064db1b1f6050b52c5d169');
INSERT INTO Acronym VALUES(9,'A12C4','A Un De Ces Quatres',X'd9788c3e0f0146c6871b4c56ba1fa91a');
INSERT INTO Acronym VALUES(10,'IRL','In Real Lifetime',X'd9788c3e0f0146c6871b4c56ba1fa91a');
INSERT INTO Acronym VALUES(11,'AFAIK','As Far Antionio Is Known',X'11eab3ae08504f1281ea149f2ebd41b9');
INSERT INTO Acronym VALUES(14,'HTH','Hope That Helps',X'7b7e4d46e2c04b5ca95452f40efc69b6');
COMMIT;
