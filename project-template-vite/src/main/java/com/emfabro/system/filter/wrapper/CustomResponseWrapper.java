package com.emfabro.system.filter.wrapper;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.Optional;

import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;
import org.springframework.http.HttpStatus;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.apache.commons.lang3.StringUtils.EMPTY;

public class CustomResponseWrapper extends HttpServletResponseWrapper {
    private ServletOutputStream outputStream;
    private PrintWriter writer;
    private CustomServletOutputStream output;

    public CustomResponseWrapper(HttpServletResponse response) {
        super(response);
    }

    @Override
    public ServletOutputStream getOutputStream() throws IOException {
        if (writer != null) {
            throw new IllegalStateException("output stream has already been called on this response.");
        }

        if (outputStream == null) {
            outputStream = getResponse().getOutputStream();
            output = new CustomServletOutputStream(outputStream);
        }

        return output;
    }

    @Override
    public PrintWriter getWriter() throws IOException {
        if (outputStream != null) {
            throw new IllegalStateException("output stream has already been called on this response.");
        }

        if (writer == null) {
            output = new CustomServletOutputStream(getResponse().getOutputStream());
            writer = new PrintWriter(new OutputStreamWriter(output, getResponse().getCharacterEncoding()), true);
        }

        return writer;
    }

    @Override
    public void flushBuffer() throws IOException {
        if (writer != null) {
            writer.flush();
        } else if (outputStream != null) {
            output.flush();
        }
    }

    public byte[] getBinary() {
        if (output != null) {
            return output.getBuffer();
        } else {
            return new byte[0];
        }
    }

    public String getJson() {
        return Optional.ofNullable(getBinary())
                       .map(bytes -> new String(bytes, UTF_8))
                       .orElse(EMPTY);
    }

    public boolean isOk() {
        return HttpStatus.OK.value() == super.getStatus();
    }

    private static class CustomServletOutputStream extends ServletOutputStream {
        private final OutputStream outputStream;
        private final ByteArrayOutputStream buffer;

        public CustomServletOutputStream(OutputStream outputStream) {
            this.outputStream = outputStream;
            this.buffer = new ByteArrayOutputStream();
        }

        @Override
        public void write(int b) throws IOException {
            outputStream.write(b);
            buffer.write(b);
        }

        public byte[] getBuffer() {
            return buffer.toByteArray();
        }

        @Override
        public boolean isReady() {
            return false;
        }

        @Override
        public void setWriteListener(WriteListener writeListener) {

        }
    }
}