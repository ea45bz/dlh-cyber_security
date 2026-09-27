1. **What is `content discovery`?**  
   The systematic process of finding hidden or undocumented URLs, files, and directories on a web server.

2. **Why is content discovery important?**  
   It reveals the attack surface—hidden resources, misconfigurations, and sensitive data that could otherwise be missed.

3. **How does directory `bruteforcing` work?**  
   The tool repeatedly requests URLs built from a wordlist; responses are checked for valid status codes or content to confirm existence of directories/files.

4. **What is `Gobuster` and how is it used?**  
   A Go‑based scanner that brute‑forces directories, subdomains, or DNS hosts (e.g., `gobuster dir -u https://example.com -w /path/to/wordlist.txt`).

5. **Explain the use of `Burp Suite` in content discovery.**  
   Burp’s Spider can crawl discovered URLs; its Repeater allows manual testing of guessed paths from a wordlist, and the Intruder can automate brute‑force requests.

6. **How does `OWASP ZAP` assist in content discovery?**  
   ZAP’s Active Scan and Spider automatically enumerate sites; its Fuzzer can inject common directory names for deeper enumeration.

7. **What are `wordlists` and how are they used in content discovery?**  
   Plain‑text files containing common directory or file names (e.g., admin, login.php). Tools iterate over them to discover valid resources.

8. **Describe the purpose of tools like `DirBuster`.**  
   DirBuster brute‑forces directories and files using a wordlist, reporting HTTP status codes to identify real endpoints.

9. **What are `hidden` directories and files in web security?**  
   Files or folders not exposed via normal navigation (e.g., /secret, /config/) that can contain sensitive data or admin interfaces.

10. **Explain fuzzing in the context of web security.**  
    Fuzzing sends malformed or unexpected input to a web application’s parameters, hoping to expose hidden paths, error pages, or logic flaws.
