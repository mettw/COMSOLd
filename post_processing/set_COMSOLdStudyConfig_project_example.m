function out = set_COMSOLdStudyConfig_project(project)

    switch project
        case "Giorgio"
            out = "C:\Users\Matthew\MATLAB Drive\Giorgio\configure_COMSOLdStudyConfig.m";
        otherwise
            error("COMSOLdStudyConfig(): Project not configured.");
    end
end