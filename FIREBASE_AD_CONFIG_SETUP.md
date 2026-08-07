# Firebase Remote Config - Ad Keys Setup

## Firebase Console में Keys कैसे Add करें

### Step 1: Firebase Console खोलें
1. https://console.firebase.google.com/ पर जाएं
2. अपना `movie-web-store` project select करें
3. Left sidebar में **Remote Config** पर क्लिक करें

### Step 2: नई Keys Add करें

नीचे दी गई table में सभी Parameter names और उनकी default values हैं। हर एक के लिए **Add parameter** बटन पर क्लिक करके ये keys Firebase में add करें:

---

## 📋 Firebase Remote Config Parameters Table

| **Parameter Name** | **Parameter Key** | **Default Value** | **Description** |
|-------------------|------------------|-------------------|-----------------|
| Banner 1 (468x60) | `ad_key_banner_1_468x60_online` | `f92fd51462df13e93e1549f302a4f668` | Small banner ad (468x60) |
| Banner 2 (300x250) | `ad_key_banner_2_300x250_online` | `5cb6f6899f19690a46f7d9fb4692177a` | Medium rectangle ad (300x250) |
| Banner 3 (160x600) | `ad_key_banner_3_160x600_online` | `9334562f34012e4dd1841f78d4c7d332` | Wide skyscraper ad (160x600) |
| Banner 4 (160x300) | `ad_key_banner_4_160x300_online` | `063c76c839f754d4f5f60c9988ad6e92` | Half page ad (160x300) |
| Banner 5 (320x50) | `ad_key_banner_5_320x50_online` | `dbeb85669fb7da87e9f90d8241f72b3c` | Mobile banner ad (320x50) |
| Banner 6 (728x90) | `ad_key_banner_6_728x90_online` | `14c1219b6c6a21061e2795fa9dcef8e5` | Leaderboard ad (728x90) |
| Banner 728x90 | `ad_key_banner_728x90_online` | `14c1219b6c6a21061e2795fa9dcef8e5` | Another leaderboard ad (728x90) |
| Sidebar Left (160x600) | `ad_key_sidebar_left_160x600_online` | `9334562f34012e4dd1841f78d4c7d332` | Left sidebar skyscraper ad |
| Sidebar Right (160x600) | `ad_key_sidebar_right_160x600_online` | `9334562f34012e4dd1841f78d4c7d332` | Right sidebar skyscraper ad |
| Bottom Banner (468x60) | `ad_key_bottom_468x60_online` | `f92fd51462df13e93e1549f302a4f668` | Bottom banner ad |

---

## 🔧 Firebase Console में Add करने का तरीका

### हर Parameter के लिए:

1. **Add parameter** button पर क्लिक करें
2. **Parameter key** में ऊपर table से key name डालें (जैसे: `ad_key_banner_1_468x60`)
3. **Default value** में ऊपर table से value डालें (जैसे: `f92fd51462df13e93e1549f302a4f668`)
4. **Data type** में **String** select करें
5. **Description** (optional) में ad का size और placement लिख सकते हैं
6. **Add parameter** button पर क्लिक करके save करें

### सभी Parameters Add होने के बाद:

1. ऊपर right corner में **Publish changes** button पर क्लिक करें
2. Confirmation dialog में **Publish** पर क्लिक करें

---

## ✅ Verification

Parameters publish होने के बाद:

1. अपनी Flutter app को run करें (`flutter run -d chrome`)
2. Console में ये message दिखना चाहिए: `✅ Firebase Ad Config initialized successfully`
3. अगर keys fetch नहीं हो पाईं, तो app automatically default values use करेगा

---

## 🔄 Future में Keys Update करने के लिए:

जब भी आपको ad keys बदलनी हों:

1. Firebase Console → Remote Config में जाएं
2. जिस parameter को update करना है उस पर क्लिक करें
3. **Edit** पर क्लिक करके नई value डालें
4. **Publish changes** पर क्लिक करें
5. App automatically नई keys fetch कर लेगा (1 hour के बाद या app restart पर)

---

## 📝 Notes:

- **Fetch Interval**: App हर 1 घंटे में Firebase से नई keys fetch करेगा
- **Fallback**: अगर Firebase से keys fetch fail होती हैं, तो code में hardcoded default values use होंगी
- **Web Only**: ये ad keys सिर्फ web platform पर use होती हैं
- **Key Format**: सभी keys 32-character hexadecimal strings होनी चाहिए

---

## 🐛 Troubleshooting:

### अगर ads नहीं दिख रहे:

1. Check करें कि Firebase में सभी 10 parameters add किए हैं
2. Verify करें कि parameters publish किए गए हैं
3. Browser console में errors check करें
4. App को restart करें

### Firebase Connection Issues:

अगर Firebase connect नहीं हो रहा:
1. Check करें कि internet connection है
2. Firebase project में web app properly configure है
3. `google-services.json` और Firebase config files सही हैं

---

## 🎯 Quick Copy-Paste List

Firebase Console में directly copy-paste करने के लिए:

```
ad_key_banner_1_468x60_online
ad_key_banner_728x90_online
ad_key_banner_2_300x250_online
ad_key_banner_3_160x600_online
ad_key_banner_4_160x300_online
ad_key_banner_5_320x50_online
ad_key_banner_6_728x90_online
ad_key_sidebar_left_160x600_online
ad_key_sidebar_right_160x600_online
ad_key_bottom_468x60_online
```

---

Agar koi problem aaye ya help chahiye to mujhe batayein! 🚀
