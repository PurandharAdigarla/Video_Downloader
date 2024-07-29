package com.youtubedownload.YouTube_downloader;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;

@RestController
@RequestMapping("/download")
public class DownloadController {

    @Autowired
    private YouTubeDownloadService youTubeDownloadService;

    @PostMapping
    public ResponseEntity<?> downloadVideo(@RequestParam String url, @RequestParam String quality) {
        String filePath = youTubeDownloadService.downloadVideo(url, quality);
        if (filePath != null) {
            File file = new File(filePath);
            FileSystemResource resource = new FileSystemResource(file);
            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + file.getName());
            headers.add(HttpHeaders.CONTENT_TYPE, "video/mp4");
            return new ResponseEntity<>(resource, headers, HttpStatus.OK);
        } else {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to download video.");
        }
    }
}