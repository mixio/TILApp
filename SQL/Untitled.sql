DROP TABLE "fluent";
CREATE TABLE "fluent" ("id" BLOB NOT NULL PRIMARY KEY, "name" TEXT NOT NULL, "batch" INTEGER NOT NULL, "createdAt" REAL , "updatedAt" REAL );

DROP TABLE "User";
CREATE TABLE "User" ("id" BLOB NOT NULL PRIMARY KEY, "name" TEXT NOT NULL, "username" TEXT NOT NULL);

DROP TABLE "Acronym";
CREATE TABLE "Acronym" ("id" INTEGER NOT NULL PRIMARY KEY, "short" TEXT NOT NULL, "long" TEXT NOT NULL, "userID" BLOB NOT NULL, CONSTRAINT "fk:Acronym.userID+User.id" FOREIGN KEY ("userID") REFERENCES "User" ("id"));

DROP TABLE "Category";
CREATE TABLE "Category" ("id" INTEGER NOT NULL PRIMARY KEY, "name" TEXT NOT NULL, "description" TEXT );

DROP TABLE "Acronym_Category";
CREATE TABLE "Acronym_Category" ("id" BLOB NOT NULL PRIMARY KEY, "acronymID" INTEGER NOT NULL, "categoryID" INTEGER NOT NULL, CONSTRAINT "fk:Acronym_Category.acronymID+Acronym.id" FOREIGN KEY ("acronymID") REFERENCES "Acronym" ("id") ON DELETE CASCADE, CONSTRAINT "fk:Acronym_Category.categoryID+Category.id" FOREIGN KEY ("categoryID") REFERENCES "Category" ("id") ON DELETE CASCADE);

PRAGMA foreign_keys = OFF;

INSERT INTO "fluent" VALUES (X'408E303D0AAC4F0CA2E99E1F18439060', 'User', 1, 1.53415319832453203204e+09, 1.53415319832453203204e+09);
INSERT INTO "fluent" VALUES (X'87FE8BFC7A034EAFB6ABF915A994DEF4', 'Acronym', 1, 1.53415319833243608479e+09, 1.53415319833243608479e+09);
INSERT INTO "fluent" VALUES (X'B712D944313D44DFA106307CD00F3119', 'Category', 1, 1.53415319833781290054e+09, 1.53415319833781290054e+09);
INSERT INTO "fluent" VALUES (X'A75A553F68DB4D1FB2B4465A01D5BA33', 'AcronymCategoryPivot', 1, 1.53415319834458208081e+09, 1.53415319834458208081e+09);

INSERT INTO "User" VALUES (X'FE34ACA7C0064DB1B1F6050B52C5D169', 'Joe Garmon', 'jg');
INSERT INTO "User" VALUES (X'7B7E4D46E2C04B5CA95452F40EFC69B6', 'Olivier Jacky', 'oj');
INSERT INTO "User" VALUES (X'D9788C3E0F0146C6871B4C56BA1FA91A', 'Aline Dropan', 'ad');


INSERT INTO "Acronym" VALUES (1, 'AFAIK', 'As Far AS I Know', X'FE34ACA7C0064DB1B1F6050B52C5D169');
INSERT INTO "Acronym" VALUES (2, 'OMG', 'Oh My God', X'7B7E4D46E2C04B5CA95452F40EFC69B6');
INSERT INTO "Acronym" VALUES (3, 'DIY', 'Do It Yourself', X'7B7E4D46E2C04B5CA95452F40EFC69B6');
INSERT INTO "Acronym" VALUES (4, 'SYS', 'See You Soon', X'FE34ACA7C0064DB1B1F6050B52C5D169');
INSERT INTO "Acronym" VALUES (5, 'WTF', 'What The Fool', X'7B7E4D46E2C04B5CA95452F40EFC69B6');
INSERT INTO "Acronym" VALUES (6, 'LOL', 'Laughing Out Loud', X'FE34ACA7C0064DB1B1F6050B52C5D169');
INSERT INTO "Acronym" VALUES (7, 'GNU', 'GNU is Not Unix', X'7B7E4D46E2C04B5CA95452F40EFC69B6');
INSERT INTO "Acronym" VALUES (8, 'IKR', 'I Know Right', X'D9788C3E0F0146C6871B4C56BA1FA91A');
INSERT INTO "Acronym" VALUES (9, 'A12C4', 'A Un De Ces Quatres', X'D9788C3E0F0146C6871B4C56BA1FA91A');
INSERT INTO "Acronym" VALUES (10, 'IRL', 'In Real Lifetime', X'D9788C3E0F0146C6871B4C56BA1FA91A');

INSERT INTO "Category" VALUES (1, 'Chat', 'Commonly used chat talk');
INSERT INTO "Category" VALUES (2, 'Technical', 'Commonly used technical talk');
INSERT INTO "Category" VALUES (3, 'Computer', 'Commonly used computer science');


INSERT INTO "Acronym_Category" VALUES (X'5205C8F7B7F94A6685AFB585540C48EB', 1, 1);
INSERT INTO "Acronym_Category" VALUES (X'5F0DD7AD55DB472DA515ED89A9031BB3', 2, 1);

PRAGMA foreign_keys = ON;
