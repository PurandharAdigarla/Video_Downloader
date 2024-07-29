package com.youtubedownload.YouTube_downloader;

import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
public class YouTubeDownloadService {

    private static final String DOWNLOAD_DIR = "/home/ec2-user/downloads";

    public String downloadVideo(String url, String quality) {
        // Clean up old files
        cleanDownloadDirectory(DOWNLOAD_DIR);

        String timestamp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        String fileName = "video_" + timestamp + ".mp4";

        List<String> command = new ArrayList<>();
        command.add("/usr/local/bin/yt-dlp");
        command.add("-f");
        command.add(quality);
        command.add("-o");
        command.add(DOWNLOAD_DIR + "/" + fileName);
        command.add(url);

        try {
            ProcessBuilder processBuilder = new ProcessBuilder(command);
            Process process = processBuilder.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            StringBuilder output = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }

            int exitCode = process.waitFor();
            if (exitCode == 0) {
                // To debug, print out the content of output
                System.out.println("Output: " + output.toString());
                return DOWNLOAD_DIR + "/" + fileName;
            } else {
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void cleanDownloadDirectory(String downloadDir) {
        File dir = new File(downloadDir);
        File[] files = dir.listFiles((d, name) -> name.endsWith(".mp4"));
        if (files != null) {
            for (File file : files) {
                if (file.isFile() && shouldDelete(file)) {
                    file.delete(); // Delete the file if it meets the criteria
                }
            }
        }
    }

    private boolean shouldDelete(File file) {
        // Define your criteria for deletion, e.g., files older than a certain period
        long maxAge = 24 * 60 * 60 * 1000L; // 1 day in milliseconds
        return System.currentTimeMillis() - file.lastModified() > maxAge;
    }
}