//
//  AddEndpointScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct AddEndpointScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter
    
    // Form fields
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var method: HTTPMethod = .get
    @State private var probeInterval: Int = 5
    @State private var timeout: Int = 10
    @State private var showAdvanced: Bool = false
    @State private var headers: String = ""
    @State private var requestBody: String = ""
    
    // State
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    private var isValid: Bool {
        !name.isEmpty && !url.isEmpty && URL(string: url) != nil
    }
    
    var body: some View {
        Form {
            // Basic Info Section
            Section("Basic Information") {
                TextField("Endpoint Name", text: $name)
                    .textContentType(.name)
                
                TextField("URL", text: $url)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                Picker("HTTP Method", selection: $method) {
                    ForEach(HTTPMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
            }
            
            // Probe Settings Section
            Section("Monitoring Settings") {
                Picker("Check Interval", selection: $probeInterval) {
                    Text("1 minute").tag(1)
                    Text("5 minutes").tag(5)
                    Text("15 minutes").tag(15)
                    Text("30 minutes").tag(30)
                    Text("1 hour").tag(60)
                }
                
                Picker("Timeout", selection: $timeout) {
                    Text("5 seconds").tag(5)
                    Text("10 seconds").tag(10)
                    Text("30 seconds").tag(30)
                    Text("60 seconds").tag(60)
                }
            }
            
            // Advanced Section
            Section {
                DisclosureGroup("Advanced Options", isExpanded: $showAdvanced) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Headers (JSON)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $headers)
                            .font(.system(.body, design: .monospaced))
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    if method != .get && method != .head {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Request Body")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextEditor(text: $requestBody)
                                .font(.system(.body, design: .monospaced))
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            // Info Section
            Section {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("The endpoint will be monitored from multiple global regions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Add Endpoint")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(isSaving)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Add") {
                        saveEndpoint()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Failed to create endpoint")
        }
    }
    
    private func saveEndpoint() {
        isSaving = true
        
        // Parse headers if provided
        var headersDict: [String: String]? = nil
        if !headers.isEmpty {
            if let data = headers.data(using: .utf8),
               let parsed = try? JSONDecoder().decode([String: String].self, from: data) {
                headersDict = parsed
            }
        }
        
        let request = CreateEndpointRequest(
            name: name,
            url: url,
            method: method.rawValue,
            probeIntervalMinutes: probeInterval,
            timeoutSeconds: timeout,
            expectedStatusCodes: [200, 201, 204],
            headers: headersDict,
            body: requestBody.isEmpty ? nil : requestBody
        )
        
        Task {
            do {
                let _ = try await APIClient.shared.request(
                    EndpointsAPI.create(request),
                    expecting: APIResponse<EndpointDTO>.self
                )
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isSaving = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddEndpointScreen()
    }
    .environmentObject(AppRouter())
}
