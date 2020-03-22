//
//  Constants.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 12/27/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

struct Constants {
    static let registerSegue = "toRegistrationScreen"
    static let loginSegue = "toLoginScreen"
    static let registerToLoginSegue = "fromRegisterToLogin"
    static let loginToMainSegue = "fromLoginScreen"
    static let moduleToChapterSegue = "fromModulesToChapters"
    static let chapterToQuestionsSegue = "toQuestions"
    static let loginToAdminSegue = "toAdminScreen"
    static let plannerToTaskSegue = "toTaskView"
    static let toPlannerSegue = "toPlannerView"
    static let questionToQBSegue = "toQuestionBank"
    static let toModuleSegue = "toModule"
    static let consultationSegue = "toConsultation"
    static let settingsSegue = "toSettings"
    static let paymentsSegue = "toServices"
    static let scholarshipsSegue = "toScholarship"
    static let groupChatSegue = "toGroupChat"
    static let aboutUsSegue = "toAboutUs"
    static let collegeDetailsSegue = "toCollegeDetails"
    static let groupChatRegisterSeque = "toGroupChatRegister"
    static let toChatWindowSegue = "fromChatRegToWindow"
    static let toGrammarWindowSegue = "toGrammarValidation"
    static let fromRegToGrammarSegue = "fromRegToGrammar"
    static let toResourcesSegue = "toResources"
    static let toCollegePlannerSegue = "toCollegePlanner"
    static let toCollegeVisitSegue = "toCollegeVisit"
    static let toACTResourceSegue = "toACTResource"
    static let toSATResourceSegue = "toSATResource"
    static let sampleProfileSegue = "toSampleProfile"
    static let guidedQuestionSegue = "toGuidedQuestion"
    static let raiseGPASegue = "toRaiseGPA"
    static let fromResourceToSectionSegue = "toSection"
    static let toPaymentFormSegue = "toPaymentForm"
    static let toAvatarsSegue = "toAvatars"
    static let editProfileAvatarSegue = "editProfileAvatar"
    static let toStudentProfileSegue = "toStudentProfile"
    static let toProfileSegue = "toProfileDisplay"
    static let toChangBackgroundSegue = "toChangeBackground"
    static let toAddTaskSegue = "toAddTask"
    
    static let cellNibName = "CustomMessageCell"
    static let chatCellIdentifier = "ReusableCell"
    static let moduleCell = "ModuleCell"
    static let chapterCell = "ChapterCell"
    static let profileCell = "StudentProfile"
    static let plannerCategoryCell = "PlannerCategoryCell"
    static let taskCategoryCell = "ToDoItemCell"
    static let resourcesCell = "ResourcesCell"
    static let avatarCell = "AvatarCell"
    static let backgroundCollectionCell = "BackgroundCollectionCell"
    
    static let defaultEmailAddress = "VoicEDCollegeEmail"
    static let saveRegistrationEmail = "SaveRegistrationEmail"
    static let biometricScan = "SaveBiometricScan"
    static let notFirstTime = "NotFirstTimeCategory"
    static let notFirstTimeResources = "NotFirstTimeResources"
    static let fullName = "VoicEDFullName"
    static let resignFromMainMenu = "ResignFromMainMenu"
    static let backToChatRegister = "BackToChatRegister"
    static let backToQuizRegister = "BackToQuizRegister"
    static let signedUpForNotify = "SignedUpForNotify"
    static let askedToNotify = "AskedToNotify"
    static let supportEmail = "SupportEmail"
    static let supportPhone = "SupportPhone"
    static let avatarImage = "AvatarImage"
    static let chatBackgroundImage = "ChatBackgroundImage"
    static let backFromAddTask = "BackFromAddTask"
    static let updateAvatarImage = "UpdateAvatarImage"
    static let backFromProfileTableView = "BackFromProfileTableView"
    
    static let collegeEssayText = "VoicED provides expert guidance in essay writing for a wide range of colleges to help alleviate the stress related to the college admissions process. The success of each student is the most crucial part of the process. Click the button below to get started with the application process."
    static let collegeConsultingText = "We can help you navigate the ins and outs of the college admissions process, master the skills needed to put together a winning college application, and even help you get a running start on your first day of classes at the college of your dreams, increasing your chances for long-term success. Click the button below to get started with the college counseling application process."
    static let grammarClassText = "We offer courses on academic writing and mastering college-level grammar and mechanics. Our grammar and writing classes are one of the best you can find. Articulate well and make an impression with every sentence you write. Click the button below to get started with the application process."
    
    static let rouletteContentDict = ["Grammar": "Take English Grammar quiz and have the results emailed to you for  your analysis later", "Services" : "Register for College Essay Prep. services, College Consulting, Classes on Grammar & Academic Writing, and connect with us on Facebook, Instagram, Twitter or by phone", "Resources": "Valuable resources like good study habits, campus visits & Application Organizer, sample profiles of admitted students, SAT/ ACT Links, tips on raising your GPA, and tips on getting admitted to favorite schools", "Consultation": "Provide us your stats and we will contact you to let you know your strengths and weaknesses and how you can maximize your chance of getting in to the college(s) of your choice", "Scholarships": "Very informative page on various Scholarship options available that you can avail of when applying to colleges", "Settings": "Change you password to access this app, get your college planner to-do list emailed to your email address, provide feedback about this app and our services", "Admissions Planner": "As you prepare for admissions to colleges, track your progress using this feature containing a list of mandatory tasks and the option to add your own", "Group Chat": "Chat with other users of this app and exchange ideas and important information regarding college admissions"]
    
    static let resourcesArray = ["Good Study Habits & Positive Mentality", "College Visits & Application Organizer", "College Visit Worksheet", "Profiles & Essays of Admitted Students", "How To Raise Your GPA", "Preparing for ACT- 1.5MB File", "Preparting for SAT- 5MB File", "SAT Practice Test 1 Scoring", "SAT Practice Test 1- 3.1MB File", "SAT Practice Test 1 Essay", "SAT Practice Test 1 Answers", "SAT Answering Sheet- 1.6MB File", "SAT Practice Test 2 Scoring", "SAT Practice Test 2- 2.7MB File", "SAT Practice Test 2 Essay", "SAT Practice Test 2 Answers", "SAT Practice Test 3 Scoring", "SAT Practice Test 3- 3.1MB File", "SAT Practice Test 3 Essay", "SAT Practice Test 3 Answers"]
    
    static let pictureArray = ["picture1", "picture2", "picture3", "picture4", "picture5", "picture6", "picture7", "picture8", "picture9", "picture10", "picture11", "picture12", "picture13", "picture14", "picture15", "picture16", "picture17", "picture18", "picture19", "picture20", "picture21", "picture22", "picture23", "picture24", "picture25", "picture26", "picture27", "picture28", "picture29", "picture30", "picture31", "picture32", "picture33", "picture34", "picture35", "picture36", "picture37", "picture38", "picture39", "picture40", "picture41", "picture42", "picture43", "picture44", "picture45", "picture46", "picture47", "picture48", "picture49", "picture50"]
    
    static let avatarArray = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8", "avatar9", "avatar10", "avatar11", "avatar12", "avatar13", "avatar14", "avatar15", "avatar16", "avatar17", "avatar18", "avatar19", "avatar20", "avatar21", "avatar22", "avatar23", "avatar24", "avatar25", "avatar26", "avatar27", "avatar28", "avatar29", "avatar30", "avatar31", "avatar32", "avatar33", "avatar34", "avatar35", "avatar36", "avatar37", "avatar38", "avatar39", "avatar40", "avatar41", "avatar42", "avatar43", "avatar44", "avatar45", "avatar46", "avatar47", "avatar48", "avatar49", "avatar50", "avatar51", "avatar52", "avatar53", "avatar54", "avatar55", "avatar56", "avatar57", "avatar58", "avatar59", "avatar60", "avatar61", "avatar62", "avatar63", "avatar64", "avatar65", "avatar66", "avatar67", "avatar68", "avatar69", "avatar70", "avatar71", "avatar72", "avatar73", "avatar74", "avatar75", "avatar76", "avatar77", "avatar78", "avatar79", "avatar80", "avatar81", "avatar82", "avatar83", "avatar84", "avatar85", "avatar86", "avatar87", "avatar88", "avatar89", "avatar90", "avatar91", "avatar92", "avatar93", "avatar94", "avatar95"]
    
    static let categoryArray = ["Internship hours log", "My Passion Project", "Letters of Recommendations", "Competitions", "Work Related Experience", "My Titles and Designations", "Description of My Extracurriculars", "Scholarships", "Short Term Goals", "Long Term Goals", "List of Majors", "My Summer Plans"]
    
    static let quizSecondsRemaining = 60
    static let scholarshipArticle = "https://voiced.academy/how-to-fund-your-college-education-and-where-is-the-money/"
    static let collegeEssayArticle = "https://voiced.academy/essay-preparation-services/"
    static let collegeCounselArticle = "https://voiced.academy/college-counseling-application/"
    static let grammarClassArticle = "https://voiced.academy/class-registration-form/"
    static let voicedAcademy = "https://voiced.academy/"
    static let facebookLink = "https://www.facebook.com/groups/405823736733109/"
    static let instagramLink = "https://www.instagram.com/voiced.academy/"
    static let twitterLink = "https://twitter.com/VoicED_live"
    static let phoneNumber = "14083738953"
    static let consultPaymentForm = "https://voicedacademy.com/voiced-college-consult"
    static let fcmURL = "https://fcm.googleapis.com/fcm/send"
    static let firestoreServerKey = "key=AAAAe5CuI2s:APA91bGGtXTIbdzwE231Lf7k4ho1lScDv1hs-S3h_UaDRC87rCsIEZ_kocL4hAlzOemi9xdYGacEah0Mzv-eNS9l0mbx2ufA0heRN3pD9gFV2fjfoKlZusoNTqd4RjIRkSEmGGobcyC2"
    static let grammarID = "com.voiced.CollegeConsulting.GrammarQuiz"
    static let aerospaceEngineeringatMITProfileID = "com.voiced.CollegeConsulting.AerospaceEngineeringatMIT"
    static let biomedicalEngineeringatUCIrvineProfileID = "com.voiced.CollegeConsulting.BiomedicalEngineeringatUCIrvine"
    static let computerScienceMajoratUrbanaProfileID = "com.voiced.CollegeConsulting.ComputerScienceMajoratUrbanaChampaign"
    static let electricalEngineeringatDukeProfileID = "com.voiced.CollegeConsulting.ElectricalEngineeringatDuke"
    static let engineeringPhysicsMajoratCornellProfileID = "com.voiced.CollegeConsulting.EngineeringPhysicsMajoratCornell"
    static let psychologyMajoratSmithCollegeProfileID = "com.voiced.CollegeConsulting.PsychologyMajoratSmithCollege"
    static let deleteIcon = "delete-icon"
    
    static let studyHabitsResource = "https://voiced.academy/good-study-habits-and-positive-mentality-in-high-school/"
    static let collegePlannerResource = "https://voiced.academy/wp-content/uploads/2020/02/College-Planner.pdf"
    static let collegeVisitResource = "https://voiced.academy/wp-content/uploads/2020/02/CollegeVisitWorksheet.pdf"
    static let howToRaiseGPAResource = "https://voiced.academy/how-to-boost-your-gpa-and-succeed/"
    static let linkACTResource = "https://voiced.academy/wp-content/uploads/2020/02/Preparing-for-the-ACT.pdf"
    static let linkSATResource = "https://voiced.academy/wp-content/uploads/2020/02/Preparing-for-the-SAT.pdf"
    static let SAT1ScoringResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-1-scoring.pdf"
    static let SATTest1Resource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-1.pdf"
    static let SAT1EssayResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-1-essay.pdf"
    static let SAT1AnswersResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-1-answers.pdf"
    static let SATAnsweringSheetResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-answering-sheet.pdf"
    static let SAT2ScoringResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-2-scoring.pdf"
    static let SATTest2Resource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-2.pdf"
    static let SAT2EssayResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-2-essay.pdf"
    static let SAT2AnswersResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-2-answers.pdf"
    static let SAT3ScoringResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-3-scoring.pdf"
    static let SATTest3Resource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-3.pdf"
    static let SAT3EssayResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-3-essay.pdf"
    static let SAT3AnswersResource = "https://voiced.academy/wp-content/uploads/2020/02/sat-practice-test-3-answers.pdf"
    
    struct FStore {
        static let collectionName = "Messages"
        static let senderField = "sender"
        static let senderName = "senderName"
        static let bodyField = "body"
        static let avatarName = "avatarName"
        static let dateField = "dateCreated"
        
        static let teacherCodeCollection = "TeacherCode"
        static let teacherCode = "TeacherCode"
        
        static let userCollection = "UserData"
        static let userEmailAddress = "UserEmailAddress"
        static let teacherMemberID = "TeacherMemberID"
        
        static let modulesCollection = "Modules"
        static let paidModulesCollection = "PaidModules"
        static let moduleName = "moduleName"
        
        static let chapterCollection = "Chapters"
        static let chapterName = "chapterName"
        static let moduleForChapter = "moduleForChapter"
        
        static let questionCollection = "QuestionBank"
        static let questions = "Questions"
        static let chapterForQuestions = "Chapter"
        
        static let badgeCollection = "GrammarBadge"
        static let testCollection = "GrammarTest"
        
        static let taskCollection = "Tasks"
        static let taskName = "TaskName"
        
        static let plannerCollection = "Planner"
        static let plannerName = "PlanCategory"
        
        static let phoneCollection = "SupportPhone"
        static let phoneNumber = "PhoneNumber"
        
        static let emailCollection = "SupportEmail"
        static let emailAddress = "EmailAddress"
        
        static let notificationCollection = "Notifications"
        static let fcmToken = "fcmToken"
        
        static let profileCollection = "Profiles"
        static let profileName = "ProfileName"
        static let additionalInfo = "AdditionalInfo"
        static let webLink = "WebLink"
        
        static let profilePurchaseCollection = "PurhasedProfile"
        static let purchaser = "Purchaser"
        static let productID = "ProductID"
        static let purchasedProfile = "PurchasedProfile"
        static let purchased = "Purchased"
        
        static let dateCreated = "dateCreated"
    }
}
