package controller;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.common.BitMatrix;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;

public class BarcodeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing code parameter");
            return;
        }

        response.setContentType("image/png");

        try {
            int width = 500;
            int height = 100;

            String widthParam = request.getParameter("width");
            String heightParam = request.getParameter("height");
            if (widthParam != null) {
                try {
                    width = Integer.parseInt(widthParam);
                } catch (NumberFormatException ignored) {}
            }
            if (heightParam != null) {
                try {
                    height = Integer.parseInt(heightParam);
                } catch (NumberFormatException ignored) {}
            }
            
            // Generate barcode using ZXing
            BitMatrix bitMatrix = new MultiFormatWriter().encode(code, BarcodeFormat.CODE_128, width, height);
            
            BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
            for (int x = 0; x < width; x++) {
                for (int y = 0; y < height; y++) {
                    image.setRGB(x, y, bitMatrix.get(x, y) ? 0x000000 : 0xFFFFFF);
                }
            }

            try (OutputStream out = response.getOutputStream()) {
                ImageIO.write(image, "png", out);
            }
        } catch (Exception e) {
            throw new ServletException("Failed to generate barcode image", e);
        }
    }
}
