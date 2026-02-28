---
title: General troubleshooting
---

# <img src="../images/icon.png" width="24"> General Troubleshooting

## <img src="../images/icon.png" width="20"> Ad Blockers

Ad blockers can prevent AdMob from loading ad resources, block network calls to Google’s ad servers, or hide rendered ad views, which results in missing impressions, zero-fill rates, or seemingly “stuck” loading states. Because these failures happen outside your app’s control, AdMob won’t report clear errors. Potential blocking can be detected by checking for repeated load failures with no error codes, monitoring network logs for blocked Google ad domains, or prompting users to disable known system-wide blockers (VPN-based, DNS-based) when ads consistently fail. In production, the only reliable remedy is asking users to whitelist the app or disable the blocking service.

## <img src="../images/icon.png" width="20"> DNS Settings

DNS settings can affect AdMob by causing ad-request failures if the device or network cannot properly resolve the domains used by Google’s ad and consent services. Misconfigured DNS (including privacy-filtered DNS or restrictive enterprise DNS) may block or misroute requests, leading to missing ads, slow loads, or consent-flow errors. Issues can be detected by checking device logs for failed hostname resolutions, testing with a different DNS provider (e.g., Google Public DNS or the ISP’s default), or trying another network to confirm whether DNS is the cause. To remedy problems, users should switch to a reliable DNS provider, disable overly aggressive filtering, ensure required Google domains are allowed, and verify that VPNs or DNS-based firewalls aren’t interfering with ad traffic.

## <img src="../images/icon.png" width="20"> Regional Restrictions

AdMob is not available everywhere. A list of restricted countries and regions can be found at the link below.

- [Regional Restrictions](https://support.google.com/admob/answer/6163675?hl=en)